# petersons
Reference impl of the PETERSON algorithm in Ada

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
