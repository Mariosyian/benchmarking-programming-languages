# Benchmarking Programming Languages

COMP30040 - 3rd Year Project - Benchmarking Programming Languages by Marios Yiannakou.

Supervisor: Bijan Parsia (bijan.parsia@manchester.ac.uk)

# Introduction
This project tackles/investigates the [*The Computer Language Benchmarks Game (Wikipedia)*](https://en.wikipedia.org/wiki/The_Computer_Language_Benchmarks_Game). An open-source software project, whose aim is to compare the implementations of a subset of simple algorithms in a plethora of programming languages, and determine (based on predetermined metrics) which is fastest in producing a result.

Helpful links:
- [The Computer Language Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/)
- [Repository](https://salsa.debian.org/benchmarksgame-team/benchmarksgame)
- A [repo](https://github.com/PlummersSoftwareLLC/Primes) similar to the Computer Language Benchmarks Game that runs a prime sieve program in different language.

- ## Problem
The project does not tackle a *problem* per say. Based on your definition of what a problem is of course.

Here, the term *problem* will be used as an "obstacle in the way" of achieving the desired goal. An element introduced or discovered whilst researching the project, which has caused progress to come to a halt. The lack of active development on the source code can be considered a problem, but not the goal that needs to be achieved.

- ## Suggested resolution
A method of making progress towards the desired goal (e.g. resolving the "problem" described above), would be to expand upon existing algorithm test suites, improve the efficiency of existing algorithms to create a more fair comparison, or introduce new algorithms altogether.

Each of said resolutions can be done on a single or multiple programming languages. A good plan would be to focus on a single language to get a feel of how the process works, possibly open a pull-request and see how the general public reacts, before proceeding on multiple language implementations.

# Goals
- ## Personal
The main goal I wish to achieve out of this project, is discover programming languages which are considered unconventional (whether that be in a university or industrial setting), and would otherwise not have a chance to explore. As a consequence of writing the same problem in different languages, I believe this might cause an acceleration in the learning process, as I would need to only translate code from one language to the next. An excellent method, in my opinion, to quickly learn the syntax of many languages, as the result is clear. One needs to focus on 'the journey'.

Another goal is to cultivate my knowledge for efficient algorithm implementation, a basic necessity for someone with the title of "Computer Scientist". Being able to write different algorithms in different languages, might help with visualisation and memorisation of said algorithms. Though the actual goal would be to eventually get to an understanding of algorithms, such as to create my own. Whether that is an extension of an existing, or a new one from scratch designed for a specific problem.

- ## Original project
The original goal for this project, as quoted from:
- the project's [wikipedia page](https://en.wikipedia.org/wiki/The_Computer_Language_Benchmarks_Game), "...comparing how a given subset of simple algorithms can be implemented in various popular programming languages."
- a ([page](https://wiki.c2.com/?GreatComputerLanguageShootout)) keeping updates regarding the project, "When I started this project, my goal was to compare all the major scripting languages..."

Any contribution to this goal is considered not only a success towards my degree project, but my personal growth and the community kept project as well.

# Plan
This project is written with easy expandability in mind (a problem I found as a beginner with the original shootout and the Primes repo).

Write a suite of microtasks (known algorithms, mini programs i.e. <100 LOC) and benchmark them in many languages. The microtasks serve as a means of expanding the number of programming languages I can write a basic program in (i.e. tests that I can use programming concepts such as loops, conditionals, functions, etc). These will be timeboxed strictly as the program is known and something most people have probably come across during their career (job, studies, etc), and hence will only require basic Google searches or even one week of the languages "Getting started" tutorial to learn.

Write a mid-size program (have chosen a shaved down version of a markdown parser) which will be specced by myself with the aim of being realistic as to how much I can implement in a short amount of time (about 4 weeks) and in a generous, but conservative number of languages. I'm not expecting that the markdown parser will have as many language implementations as the micro tasks, but should have at least 1 that I consider 'exotic' for myself (i.e. not any languages I consider myself comfortable or familiar with).

# Requirements
You will require to be in a Linux environment for the provided script to work as it runs on the `bash` shell and uses the UNIX output redirection / file manipulations. I personally used `Ubuntu 20.04.1` with kernel version `5.11.0-38-generic`.

# Usage
A general purpose (and hopefully easily expandable) `benchmark.sh` bash script has been written and will continue to be developed/optimised to accommodate any new languages introduced either by myself or any community member that stumbles across this project :).
```
# Navigate to the root of this repository
$ ./benchmark.sh
# View the benchmark report
$ more ./benchmarks/benchmarks
	LANGUAGE	|	ALGORITHM	|	ELAPSED (s)	|	Avg. CPU (%)	|	Avg. RSS (KB)	|	Avg. VMS (KB)
	python		|	sieve		|	00:04		|	61		        |	7055		    |	12949
```

## Java
In order to use the JUnit testing framework with VSCode, the following need to be added to your `settings.json`:
```
"java.project.referencedLibraries": [
	"lib/**/*.jar",
		// Absolute path to junit.jar
		"~/git/benchmarking-programming-languages/dependencies/junit/junit-4.10.jar"
],
```
