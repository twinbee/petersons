---------------------------------------------------------------
-- Author:	Matthew Bennett
-- Class:		CSC410 Burgess
-- Date:		09-21-04 							Modified: 9-21-04
-- Desc:		Assignment 3: PETERSON'S ALGORITHM 
--	a simple implementation of
--		PETERSON's algorithm which describes
--		mutual exclusion, fairness, and deadlock avoidance
--  	n processes (TASKS) assuming fair hardware.
--	This algorithm is famed for simplicity and undestandability.
--	PETERSON'S as described in
--  	"Algorithms for Mutual Exclusion", M. Raynal
--  	MIT PRESS Cambridge, 1986 ISBN: 0-262-18119-3
-- 		Originally from the 198x paper:
--		"Myths about the mutual exclusion problem"
----------------------------------------------------------------
-- dependencies

-- style note: the reason I sometimes "with" in but do not "use" packages
--  are the same reasons a competent C++ programmer does--as a style
--	convention--to avoid crowding of the namespace but more importantly
--	to be very explicit where abstract data types and methods are coming from.
--	for instance, the line 		 -- G : Ada.Numerics.Float_Random.Generator; 
--	is much more explicit than -- G : Generator; 

WITH ADA.TEXT_IO; 						USE ADA.TEXT_IO;

WITH ADA.INTEGER_TEXT_IO; 		USE ADA.INTEGER_TEXT_IO;

WITH ADA.NUMERICS.FLOAT_RANDOM; --USE ADA.NUMERICS.FLOAT_RANDOM;

WITH ADA.CALENDAR; 						--USE ADA.CALENDAR;
-- (provides cast: natural -> time for input into delay)

WITH ADA.STRINGS; USE ADA.STRINGS;

----------------------------------------------------------------
-- specifications

PROCEDURE as3 IS
	--globals to all tasks: Generator, constant scale factor, turn[]. flag[]
	G : Ada.Numerics.Float_Random.Generator;-- yields a random Natural after seed

	MAX_TASKS : CONSTANT := 100; --global constant for mem allocation restriction

	RANDOM_SCALE_FACTOR : CONSTANT := 50.0;
		--used to increase "spread" of random delays

  SPACES : STRING(1..80) := (Others => ' ');

	turn : ARRAY(0..MAX_TASKS-1) OF Integer := (OTHERS => -1);
		--array of TURN for all processes, initialized to -1
	flag : ARRAY(0..MAX_TASKS) 	 OF Integer := (OTHERS =>  0);
		--array of flags for all processes, initialized to 0

 --here comes the specification for our processes (TASKs)
	TASK TYPE single_task IS
		ENTRY start (	id_self : IN Integer;
									tasks_user : IN Integer;
									iterations_in : IN Integer);
		--"ENTRY start is like the constructor for a task"
	END single_task; 

	-- "since TASK TYPE single_task is part of PROCEDURE dekker,
	-- we must define it here or in a specifications file "
	TASK BODY single_task IS

				--variables defined at task creation time
			n : Integer;					--total number of tasks--"n" is used
														--to keep our code looking like the book's
			i,j : Integer;				-- identity, other task identity
			iterations : Integer;	-- # of iterations

			fallthrough : BOOLEAN; --kludge, 1st half of conditional (FIX IT!)

	BEGIN --single_task
	-- this is EISENBURG / MACGUIRE ALGORITHM implementation, the tasks themselves

	ACCEPT start (id_self : IN Integer;
								tasks_user : IN Integer;
								iterations_in : IN Integer) DO
				n := tasks_user;
				i := id_self;
				iterations := iterations_in;
	END Start;

	FOR iteration_index IN 1 .. iterations LOOP
--!!-- start of Eigenberg's algorithm (optimized knuth's)
	DELAY (Standard.Duration((Ada.Numerics.Float_Random.Random(G)
														+ RANDOM_SCALE_FACTOR) ) );
		--give the other guys a fighting chance

	-- Begin Peterson Algorithm
	FOR j in 0..(n-2)
	LOOP
		flag(i) := j;
		turn(j) := i;
		LOOP
			fallthrough := true;
			FOR k IN 0..(n-1) LOOP
				IF ( k /= i AND NOT ((flag(k) < j) OR (turn(j) /= i))) THEN
					fallthrough := false;
				END IF;
			END LOOP;	 -- "universal quantifier" loop
			EXIT WHEN (fallthrough = true); --"wait until" condition
		END LOOP;
	END LOOP;
		
	-- Critical Section --
	Put(i, (80/i - 8 ) );
	Put_Line(" in CS");
	DELAY (Standard.Duration((Ada.Numerics.Float_Random.Random(G)
														* RANDOM_SCALE_FACTOR) ) );
	Put (SPACES(1..(80/i - 8 )) );
	Put ("Turn Array: "); 
	FOR turn_index in 0..(n-2) LOOP put(Turn(turn_index),0); put (" ");	END LOOP; 
	put_line("");
	Put(i, (80/i - 8) ); -- outputs i to column 
	Put_Line (" out CS");
	-- End of the Critical Section -- 
				
		flag(i) := -1;
	
	END LOOP;
END single_task;


PROCEDURE driver IS
--implementation of the driver and user interface
--PLEASE NOTE: no global variables! these are local to the driver

  --variables that are user defined at runtime--
		iterations_user : Integer;
  	-- iterations per task, defined at execution time
		tasks_user  		: Integer RANGE 0..MAX_TASKS;
		-- num tasks, defined at execution time
		seed_user  		: Integer RANGE 0..Integer'LAST;
		-- random seed, provided by user

  --we have to use a pointer every time we throw off a new task
		TYPE st_ptr IS ACCESS single_task; --reference type
		ptr : ARRAY(0..MAX_TASKS) OF st_ptr; --how do we allocate dynamically?

BEGIN --procedure driver; user input and task spawning

	put("# random seed:       ");
	get(seed_user); --to ensure a significantly random series, a seed is needed
									-- to generate pseudo-random numbers
 	Ada.Numerics.Float_Random.Reset(G,seed_user); --like seed_rand(seed_user) in c

	--sanity checked on the input
	LOOP
		put("# tasks[1-50]:       ");
		get(tasks_user);
		EXIT WHEN (tasks_user > 0 AND tasks_user <= 50);
	END LOOP;
	LOOP
		put("# iterations[1-50]:  ");
		get(iterations_user);
		EXIT WHEN (iterations_user > 0 AND iterations_user <= 50);
	END LOOP;

	-- For each task, start it and pass its id and number of iterations
	FOR tasks_index IN 0 .. (tasks_user-1)
	LOOP
		ptr(tasks_index) := NEW single_task;
		ptr(tasks_index).Start(tasks_index, tasks_user, iterations_user);
	END LOOP;

END driver;

BEGIN --as3
	driver; --procedure call, sepration of functionality and variables
END as3;
