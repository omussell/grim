# GRIM

Create an infrastructure with an emphasis on security, resiliency and ease of maintenance. 

## End Goal

Produce a working implementation of a secure, resilient and easy to maintain infrastructure. This will be published in the form of version-controlled configuration documents, with the philosophy and background of the chosen configuration documented here. Anyone should be able to download the base operating system, and the configuration documents should convert that base OS into the desired state. 

The documentation on this site is split into two sections, Design and Implementation. The Design documents what the infrastructure *should* look like in high level terms while never actually stating particular tools. The Implementation is a working version that follows the design.

A secondary objective is to allow users to choose which software to use by having each component of the infrastructure being modular and interchangable. So while a particular tool may be used for a given task, the implementation should be seen as guidance only of what can be achieved using the design.


## Background

The intent is for the infrastructure to work well even without administrator intervention. The design is aimed at organisations that have strict security and uptime requirements (government/critical physical infrastructure), although there is nothing preventing other organisations from adopting this design and/or changing it to suit them.

[infrastructures.org]: http://www.infrastructures.org
[Bootstrapping an Infrastructure]: http://www.infrastructures.org/papers/bootstrap/bootstrap.html
[Why Order Matters: Turing Equivalence in Automated Systems Administration]: http://www.infrastructures.org/papers/turing/turing.html
