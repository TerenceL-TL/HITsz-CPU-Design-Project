# HITsz-CPU-Design-Project

---

This is a CPU Design Course offered by HITsz in 2024 Summer. I achieved a final score 100/100 in this course. 

**NOTES**

1. comp2012: main directory, including single_cycle and pipeline CPU sources.
2. Theory: Chinese Instructions for the course.
3. Reference: MiniRV and MiniLA Instructions
4. onboard_trace: Trace Test after Implementing the code on FPGA board.

*"cdp-test" is for trace, use it after uncommenting the macro "USE_TRACE" in defines.vh, and place all the source code in mySoC*

**How to Run Trace**

1. Place The Source Code in cdp_tests/mySoC/
2. Uncomment the  macro "USE_TRACE" in defines.vh.
3. cd ROOT_DIR/cdp-tests/
4. make
5. python3 run_all_tests.py

*Instructions can be found in https://comp2012.pages.dev/*
