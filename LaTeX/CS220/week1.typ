#set align(center)
= CS 220: Synthesis of Digital Systems

#set align(left)
= Week 1: Monday

== Course overview
- Course has been changed two years ago, slight differences between course description
- RTL Digital Design, along with synthesis of digital systems
- Big on semiconductor industry
- synthesis and physical design
- Course is project heavy, 60% of the grade comes from final project. Using HDL (verilog for logic design; 0 regerts)

== True Graduate Course
- Prepares a semiconductor industry career
- No exams, you structure learning and CV
- Lots of freedom with creativity on design project
- Focus on both industry and research

== Student Scholars
- Be resourceful, search academic papers and technical tutorials
- Work as a team!

== Work 
- Anything RTL, digital circuit design engineer
- Can design custom chip design, like TPUs, ASIC, CPU Micro-arch

== Course content
=== Part 1: Review digital circuits
- CMOS Tech
- Logic design

=== Part 2: Digital design flow
- Verilog RTL
- Logic synthesis
- Timing analysis
- Power analysis
- Verification
- Desgin for test

=== Part 3: Digital design techniques
- Low-power optimization
- Advanced arthimentic units
- Advanced memory design
- Emerging SoC design

=== Part 4: Final design project
- This comes a lot later


#pagebreak()

== Related Courses
Transistor-Level digiatal IC and VLSI
- EE 134: Digital Integrated Circuit Desgin
- EE 162: Intro to Nanoelectronics
- EE 168: Intro to VLSI
- EE 278: Advanced VLSI Systems

Arch and EDA (Later fill it out to maybe take an undergrad class)
- CS 161
-

== Rereq knowledge
- CS161: Computer arithmetic, pipelining, cache, etc
- EECS 120A: RTL Design, Boolean alg, combination & seq logic, etc
- Basic CMOS transistor understanding

- Most labs are simulations (wonderful, no hardware req)

== Team Forming
- Design project is team based (teams of three)
- Google sign-up will be shared after Wednesday's class
- Same team until final design project, lab assignments submitted individually

== Lab Assignments
- Meant as tutorials for final design project
- Lab write-ups are submitted individually
- 20% of grade

== Online quizzes
- 4 quizzes, each 5% grade, multiple choice / TF
- Each quiz is 2 lectures worth of material
- Can submit quiz multiple times until deadline, you get your answer
- Done through Canvas

#pagebreak()
== Design project
- Heavy focus on RTL coding and synthesis of complex digital systems
- Don't start from scratch, work on top of open source resources with a baseline
- Seek an existing RTL design and synthesize as baseline, then introduce new optimizations
- Potential project scope:
  - General-puropose processor
  - AI Accelerator
  - Image processor
  - Memory controller
  - Communication controller
    - Communication protocol can be real interesting, part of 122A final
- More suggestions discussed next class!
- Students work in teams

=== Grade:
- Worth 60% final grade
- W3: Project presentation & proposal for instruction approval (10%)
- W7: Midterm progress report (10%)
- W10: Project presentation (20%), final report & deliverable (20%)
- Grading rubric will be released

=== One-on-one project update
- 3 sessions will be used for team-based Q&A with instructor
- Use sign-up sheets to reserve timeslots

== CEQ Questions
- Up to 2 Capstone Experience Problem (CEP) problems may be earned in CS220
- CEP QUestions will be administered through optional lab questions in Lab2
  - Pass/fail for each question
  - They would be two optional CEP questions
- Questions not very difficult (horay!)

== Grading!
- Standard scale, not curved, no competition, everyone should get an A
- Final Design (60%), lab (20%), Online Quiz (20%)

== Course Schedule 
- Courses marked in green are presentations
- Courses marked in red are one-on-one updates

== Canvas & Comm
- Everything through Canvas

== AI and Assignments
- No AI check, but we are responsible for slop and factually wrong slop. Wrong responses are marked as wrong. Students responsible for clear and scientific write-ups. You better be responsible for human write ups and correct answers

#pagebreak()
#set align(center)
= Intro to Semiconductor Industry

#set align(left)

- Chips start with a design, work for a company that design their own chips
- Many fabless chip firms, they design the chips then outsource the manufacturing of these chips
  - They send the design over to the fab
- Foundries, they fabricate the chips for a living, intense process
- Design and manufacturing are two different things. Some unique companies make both, they are Integrated Device Manufacturers.
- Samsung, Intel, Micro, TI, all design and build their own chips 
- Another company does Testing, Packaging, & Assembly of these chips. Need to test the tolerance and the yield. Need to see which chips are good or what is trash. After that, they can sell it/use those chips.
- Fabless Non-chip firms, they started with chip design because of cost and efficiency of these chips.
  - They design their own chips, no need to make contracts with chip firms
  - They don't sell these chips, rather, used in their own products. Google/Apple/Tesla/Amazon/Microsoft
- IP & Design Software
  - Working with synopsys, ARM, cadence, Siemens, Ansys.
  - The horrors of synopsys...
- Equipment companies make the equipment for the fabrications
  - ASML, LAM Research, TEL Tokyo Electron

- Can see that an iPhone has chips from various companies along with their own ICs
== Phases of IC Design
- Specification
- Desgin process
- IC Design
  - Circuit, layout, other data
- Manufacturing process
- Integrated Circuit (IC)
  - This still needs testing, still it's own process and valiation


Design in abstraction levels

Level | Modeling Object | Example of Modeling Object | Hardware Description Language Used

- System | Structural Circuit | Shows system like RAM and CPU connected through BUS | C/C++ SystemVerilog SystemC
- Register-Transfer Level  (RTL) | Functional circuits on the level of multibit devices, registers and data transfer between them | shows flow of data, very abstract | Verilog VHDL
- Gate Level (Gate level netlist, Logic circuit) | Circuit containing  logic gates (AND, OR, etc) and Flip-flops | CS120A stuff | Verilog VHDL
- Circuit Level (Transistor level, SPICE Netlist) | Electrical Circuit | EE100 stuff | Spice CDL

#pagebreak()

== Design Flows
For Digital IC Design
- Specification (Manual)
Everything else is automatic
- System Level Design, HLS
- RTL -> Logic Synthesis
- Gates -> Physical synthesis -> Physical 

Manual Custom design (Digital, analog,mixed-signal)
- Specification (Manual)
- Transistor level

== Basic Steps of Digital Flow
y = (a+b)&(c XOR d) &e
- Turns this into a digital circuit
- Then becomes a pure transistor level design

- Logic synthesis is an optimization problem

== FPGA vs ASIC flow
- Both start from RTL, maybe even the same RTL
- FPGA gets programmed, then can be downloaded and verified
  - FPGAs are contrained to the power and efficiency, AKA slower, less LUTs, etc
  - Programs existing hardware 
  - Typically Aerospace, Medical, Defense, more expensive cases
  - Great for prototyping with chip design
  - Design goes from FPGA, then once validated, goes onto an ASIC for cheaper
- ASIC requires fabrication then verify circuit when it arrives
  - Uses less power, cheaper, more powerful/ sufficiently powerful, smaller units
  - More complex design flow, higher NRE, slower time to market
  - Very important for mass production, relatively cheap to reproduce

#pagebreak()
== Specification
- Starts as a high level from operating temp, V, power, die area, frequency, etc. Containing a design description in plain english
  - The following is described in Min/typ/max, then all labeled in units
- PPA (Power dissipation (Power), Clock Frequency (Performance), Area (A) )

=== RTL:
- y: Output
- a,b,c: input
- y = (a+b) \* c;

RTL gets compared with logic circuit, then formal equivalence check

=== Static Timing Analysis (STA)
- Needs to guarantee that the timings work perfectly. This logic must be performed before the necessary time

=== Physical Synthesis:
Physical synthesis is the process that produces layout of logic circuit
- This is aligning the physical logic circuit to the transistor level and where each of these belong. Along with the physical distance between them.

=== Post-Layout STA
- After layout createdm, STA runs again to account parasitics

Digital Design Toolchain,
These are sepearte between front-end and backend

Frontend:  abstractions of HDL, design compiler, logic simulation, STA, formal verification, logic synthesis, timing and power constraints

Backend: Physical design into the silicone wafer. Physical validation and STA. IC Compiler and IC Validator, they only really care about the chip fitting to the specification. They don't care about the function of the chip, often outsourced labor.

=== Access to Bender (for labs & project)
Maybe I think we needs a MobaXterm and VPN to access bender...

Get access to the BCOE Bender server
ssh into dtopete\@bender.engr.ucr.edu

type dc_shell in command line to check acccess to Synopsys (design compiler)

=== Before next class
 Start forming team and thinking of project design ideas