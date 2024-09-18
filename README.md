# Distributed Task Allocation in Vehicular Parallel Edge Computing Networks

There are several folders :
1. compared_algorithms : contains GE(Greedy), RM(Resource-constrained minimization), MY(Myopic), Primal-dual(Convex optimization) and Exhaustive search for CDF.
2. functions : includes codes for message-passing algorithm.
3. model_generator : involves codes for simulation environment generation.

In 'functions' file, 
1. mp_element : updates gamma and alpha value, detailed derivation and explanation are described in our paper.
2. allo_num : calculates the associated number of vehicles.
3. delay_fun : calculates the objective function.
4. get_max_time : calculate maximum value of delay.
5. rank_msg : get k-th smallest value of the set, plz refer to our paper.
6. mp_sol : get set of x_{ia} which has the smallest objective function
7. etc : unnecessary files
