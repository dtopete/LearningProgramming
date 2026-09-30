#set align(center)
= CS218: Design and Analysis of Algorithm

== Thursday Week 0 

#set align(left)
- First day of hell...

== Covered topics
- Analysis of Algorithms
- Divide-and-conquer Algorithms
- Greedy Algorithms
- Dynamic Programming
- Graph Algorithms
- Data Structures

== Importance of Course: Typical Interview 
- Round 1: Online Assesment (OA): 2 algorithm questions
- Round 2: Technical Interview (TI): solve 2 algorithm questions 
- Round 3: Onsite interviews (or virtual): 4-6 interviews, each 45-60 minutes long, with a mix of algorithm and system design questions
- Each round has some level of algorithm problems

== Further importance
- Good alg = good efficiency, good perf, provides real-time responses 

== Solving algorithms, What makes this course hard?
- knowing how to solve the problem is not enough, understanding the classic algs and DS
- Problem Solving is the important part, problem formalization, mapping initial solutions, modifying known algorithms to find sol, implementation, and Reasoning and debugging
- Problem solving is a skill, takes a lot of practice, this is where all the main exercise takes place

== Applications
- Database
- Data mining
- Computational biology
- Computer graphics
- etc

== What makes grad level different?
- Focus on analysis
- Focus on implementing these algorithms


#pagebreak()

== Grade:
- *course policy Test* 1%
- HW: 24%
  - 5 Assignments (biweekly), two deadlines
  - Each assignment has 6 basic points, and  1-2 bonus pts
  - Count the highest four (drop lowest) 
- Exams: 75% (midterm 30%, final 45%) 
  - Oct 29 (20 pts, Thursday w5)
  - Nov 12 (20 pts, Thurs w7)
  - Dec 5 (35 pts, Sat w10)
- Bonus:
  - Class participation
  - Bonus questions on HW or exams
  - Solving challenge problems
  - Video presenting a bonus problem
- Usuaully 15% can achieve => A+
  - Recently, it has been growing with effectly using AI as a tutor

== HW (in detail)
(6% of each assignment)
- Written assignment
- Training programming problems

Challenge problems: Usually 3 problems, 0.5 pts each

- Training problems willhave an earlier deadline
- Challenge problems you can work on them beyond the deadline. If you figure a solution before last week of the quarter, you can earn half of the points
- Highest 4 out of 5 assignemnts count towards your final grade (but all content will be covered in the exam)

- Included is a written report, this is a report having an explanation as if it were an interview. The report is not being graded, but it is a requirement to get you used to the habit

== Programming Assignments
- On Codeforces
- 

== Expect time commitment
- On average, 5-7 hrs per week
- Median is around 5-10h, very tough course. Most people rated this a very difficult course, over 50% 
- The curve is quite steep, doesn't mean to slack off. This is a core course

#pagebreak()

== AI
- AI is a tool, not a replacement for learning
- You better be the one understanding the solution, not AI.

- Use homework and course material to gauge expected difficulty and style of exams, make sure you can solve them
- Three exams to help gauge progress and test preparation
- Each exam contains ~130% of total score, harder and easier problems are included, so that you can gauge your progress and test preparation
- Easy ones are half the problems, easy part of homework problems, knowing how to solve those problems from scratch. Passing grade
- Other half will be more open ended questions, req deeper understanding. Can maybe solve some of them through the course materials

- Post AI, exams have easier questions, hw is worth less points, the open ended questions are for an A/A+ in the exam

== Entrance Exam
- 5 programming problems, basic problems that cover programming, greedy, basic DP, and basic graph alg
- SHould be possible without any assistance, expectation of the class
- Shouldn't be more than 20 lines of code per solution

== Recap of what to learn in CS218
- Lots of programming
- Problem-solving skills

== Required background
- Asymptotic analysis, O, $Theta$ , $Omega$ , $omega$ , o, notations, growth of function
- Basic ideas about greedy algorithms, optimal substructure, and greedy choice property
- 


Alg are useful, require creativity/intuition, solid background in math/programming, lots of practice

- Next Lecture, Analyzing algorithms
Lower-bound analysis: How hard a problem is?

#pagebreak()
= Tuesday Lecture - Analyzing Algorithms
- Entrance exam due this weekend, just need solutions. No report required (for this one)
  - Submit the submission entry from CodeForces
- *Finish the course policy test, due next weekend*

*Back to analyzing*
- We can predict how the algorithm performs in practice
Creteria:
- Running Time (time complexity)
  - We try to measure time
- Space usage
  - Space complexity
- Cache I/O
- Disk I/O
- Network Bandwidth
- Power consumption
- Lines of code

*Tale of Gauss*
- Asked to compute the sum from 1 to 100
  - He figured out, sum = $(1+n) * n/2$
  - Other students would've done a for loop of O(n) time complexity
  - Gauss would've done a linear, O(1) time complexity

== Computational Model
What is time complexity?
- It is counting the number of "instructions" in the algorithm

Random Access Machine (RAM) model
- We have an arbitrarily large memory
- We can
  - Perform an arithmetic operation
  - Read/Write to a memory location given the address
- Unit cost for:
  - Any instruction on $w$-bit words (how large do we need for $w$?)
  - Read/write a single memory location from an infinite memory
- Cost measure: Time complexity
- Acknowledges how many times the CPU communicates with memory 
- This is a computational model
  - What resources do we have?
  - What operations are we allowed to do?
  - What is the cost of each operation?

What is "time complexity"?
- Estimate of time needed for an algorithm
- Defines "cost" of an algorithm, we first need to define what "costs" time 

Why the time complexity is O(n)? What are we counting?
- Number of operations
- Why the time complexity is *O*(n)? Why we omit the constant and lower-order terms? Why we use "asymptotic analysis"?

Starts getting messy when we start trying to define teh RAM model
- When it comes to a for loop to add numbers 1 to 100. We have 3n+2 operations because of the ++i, sum += i, and i<=n
- Then with sum= (1+n)\*n/2, we have 3 operations, 1 assignment, 1+n, n/2, then the multiplication of the two, so maybe even 4 if we include the assignment?
- Doing the complexity of each line of code gets really messy, we just look at the order of the cost. The most decisive factor. Letting us utilizy *Asymptotic Analysis*
- Analyze the *order of costs*, letting us severely abstract everything. As long as we can compare linear algorithm is slower than a constant time.
  - Great for undergrad where we just abstract and say the intuition that it is enough
== What does big-O mean?
- Asymptotically smaller than or equal to <=
- O(n), a <= b
- $Omega$, a>=b 
- $Theta$, a=b
- o, a < b
- $omega$, a>b

== Popular Classes of Functions: (Study this slide)
Constant: $Theta$(1), 1,10,1000

Log: $Theta$(log(n))

Linear

Super-linear

Exponential

...

== Comparing two functions
Commonly used functions:

c < $log(log(n))$ < logn < $log^{c_1} n$ < $n^{c_2}$ < n < nlogn < $n^{c_3}$ < $c_4 ^n$ < $n^n$

*Analyzing running time*
- RAM Model
  - For every operation, including mem access, arithmetic operations, etc, takes unit time
- Typically consider worst-case running time for general input
- Only care about order of cost for simplicty and omit constants, lower-order terms

#pagebreak()
== How does the asymptotic notation relate to the computational model (algorithm analysis)?
- Cost measure

GOal of defining computational models is to allow for asymptotic analysis
  - False, two seperate purposes

Is RAM model perfect?
```c
(int i = 0; i < n; ++i) A[i] = A[i] + 1;
// n = 10^9, 0.141072s

(int i = 0; i < n; ++i) A[i] = (long long)(i)*4323%n + 1;
// 0.580809s

// What about
for(int i = 0; i < n; ++i) A[i] = A[(long long)(i)*4324%n] + 1;
// Takes 3.24008s

```

- We then have the issue that not all CPUs are created equally. The operation cost in a CPU cycle can do certain operations faster than others. Some arithmetic operations are faster than others

== I/O Model
- Accessing memory is expensive
- We have cache in our machine
- We count the cost only if it is a "cache miss"

== Asymmetric Model
- Homie skipped through this one

== Parallel computational models
- Multiple "threads/procs" can od computation together, and share memory

== SO why the RAM model?
- Sequential setting, actually provides a way to analyze algorithms nicely

== Analysis
- Time complexity and RAM model
  - Other models exist
- Analyzing algorithms >= time complexity, other costs (space, I/O, etc), how efficient an alg is
- Analyzing problems >= lower bound of a problem, how hard an alg is

#pagebreak()
= Lower Bound Analysis
- These are quiet hard, new content and concepts

Given a problem what is the smallest cost we need to pay?
- We know algs of running time $O(n log n)$
- But what is the "best"? Are there better algorithms?

Given a sorted array and an elelent $x$, what is the "best complexity" can toy find the rank of $x$?
- Binary search needs $O(log n)$ time
- What what is the "best"? Are there better?

== Ex of lower bound proof (independent to any algorithm):
Finding the max of an array

- Input: an array of distinct elements
- Model: We only care about comparison: Each comparison is unit cost
- How many comparisons to find max of the array?

- Let's consider some algorithms for this.
- Idea 1: Always compare the chamption, use max(curr, a[i])
  - We would use n-1 comparisons
- Idea 2: (divide and conquer) single-elimination tournament?
  - Make tree of elements, start with 8 -> 4 -> 2 -> 1
  - We still have n-1 comparisons
- Can we use fewer than n-1 comparisons to find max of an array?
*Principles*: 
- If an element is not compared to others, we can't guarantee we find the max 
- If an element loses any comparisons, it can't be the max
- If an element never loses a comparison, it's possible to be the max
*Proof:*
- Call an element "free" if it hasn't been compared to anyone (hasn't been verified)
- Call an element "bad" if it loses at least one comparison (ruled out)
- Call an element "top" if it never loses any comparison (a candidate)
- Initial status: 0 top, $n$ free, 0 bad
- Final status: 1 top, 0 free, n-1 bad
What happens when comparing two elements?
- top vs top, -1 top, +1 bad
- top vs bad, top wins, nothing changes, if top wins, -1 top, +1 bad
- top vs free, top wins: -1+1 top, +1 bad, -1 free
- bad vs bad, net nothing
- bad vs free, (depends on who wins), but -1 free, then +1 top or bad
- free vs free, +1 top, +1 bad, -2 free
Each comparison increases at most 1 bad!
- We need at least n-1 comparisons to get the final status of (n-1 bad)
To get an optimal solution
=== Insight from Analysis?
- Can see any room for improvement

Going back to divide and conquer vs comparing along the memory,
D&C compares free vs free, then going along the array is comparing top vs free

== Upper vs lower bound
- *upper bound* f(n) cost of the problem means there exists an alg that takes at most f(n) steps on any input size $n$
  - This alg will get a solution
  - f(n) guaranteed to be sufficient: we don't need more than f(n) costs
- *lower bound* of g(n) means for any alg, there exists an input for which any alg takes at least g(n) steps on that input
  - What ever alg you use, you can't get better than g(n)
- When upper bound meets lower bound
  - f(n) = g(n)
*Finding max of an array*
- lower bound: n-1 comparisons
- Upper bound: compare to champion alg does exatly n-1 comparisons

#pagebreak()
== Decision trees and lower bound proof