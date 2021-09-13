# README

## About
DevMountJob is an example of a web application developed using the Domain-Driven Design approach. We start with the 
strategic DDD by running three Event Storming sessions. Then we have strategic DDD, where we use its patterns to 
implement discovered models. Moreover, we use CQRS to have a clean separation between the write and read stack. Finally, 
we use Event Sourcing as a persistence mechanism. This "all-in" approach allows us to approach clean design and has an 
educational purpose so you can see all those fancy, high abstract concepts on a real-world example! Have fun!

This repository arose from a series of posts, so you will gain max knowledge when you read them and analyze the code here. 
Below you can find the current list of them, which will be updated when a new post arrives:
1. ["See how I failed at my SaaS idea and what you will gain from it."](https://mrpicky.dev/see-how-i-failed-at-my-saas-idea-and-what-you-will-gain-from-it/) - crucial one, as there is detailed domain description included, and knowing domain i Domain Driven Design is well... crucial ;)
2. ["The story of how to NOT start a project."](https://mrpicky.dev/the-story-of-how-to-not-start-a-project/) - this one is rather optional but puts some more light on how I failed actually. Can help you avoid some mistakes while working on your side projects.
3. ["This could be the biggest post about Big Picture Event Storming ever! And with examples!"](https://mrpicky.dev/this-could-be-the-biggest-post-about-big-picture-event-storming-ever-and-with-examples/) - we start crunching the domain knowledge here. You can't miss it.  
4. Post about Process Level Event Storming - it's currently in review - **coming soon**.
5. Post about Design Level Event Storming - Text is ready, but I need to translate it to english - **coming soon**.
6. First post about implementation, CQRS, Event Sourcing - yup, the one you see here ;). This one also needs to be translated to english - **coming soon**.
7. and next ones - TBD 

Subscribe to my [newsletter](https://mrpicky.dev/loot/) to not miss new ones!

## Domain description
DevMountJob is a SaaS that would reverse the flow of the typical hiring process. The idea behind it, in general, would 
be not to have another job board but a developer board. In other words, a place that would not list job offers but 
developers looking for them instead. A place where a developer could put up an anonymous notice, delineating their own 
terms and conditions and presenting their technical profile without details such as employment history or educational 
background. Eventually, I failed to launch it (more on that in mentioned [post](https://mrpicky.dev/the-story-of-how-to-not-start-a-project/)). 
Nevertheless, now at least we have an open-sourced project where we can learn how to design and implement a project in 
a DDD approach and using the state of the art tech stack ;)

When I was developing this project for the first time, I wrote an article about the whole idea, my thoughts, and 
solutions to fix the broken hiring process. The post is still available 
[here](https://medium.com/@StolarczykT/lets-turn-the-dev-hiring-process-upside-down-62620a3f5c7c). 
It's pretty long, has a few years, and is not essential in the context of the project here, but it can give you the 
big picture. More interesting for you should be [the first post](https://mrpicky.dev/see-how-i-failed-at-my-saas-idea-and-what-you-will-gain-from-it/) 
of the series where I describe the domain in detail and why I want to share my experiences. This one is crucial if 
you're going to understand the project's code in this repository and have domain knowledge about it.

## Crunching Knowledge
DDD is not about using a set of defined patterns - it's about exploring the domain. About finding boundaries of its 
subdomains and processes. About designing models that are going to support our business processes. It means, we somehow 
need to gather domain knowledge. The perfect way would be to spend a lot of time with domain experts daily.
Nevertheless, sometimes we may have issues reaching them, or the knowledge is distributed between a few people. 
Fortunately, we can use some tools to help us with knowledge crunching. Such a tool could be Event Storming.

Event Storming is actually a set of workshops that usually consists of:
- Big Picture Event Storming (BPES)
- Process Level Event Storming (PLES)
- Design Level Event Storming (DLES)

I did all of them for this project and documented them in the greatest detail.

### Big Picture Event Storming (BPES)
In this one, we want to see, well… a big picture of the business process – we want to catch sight of participants' 
perception. As I wasn't familiar with Event Storming too much, I ask three experts to help me with BPES: [Mariusz Gil](https://twitter.com/mariuszgil), 
[Łukasz Szydło](https://twitter.com/lszydlo), [Andrzej Krzywda](https://twitter.com/andrzejkrzywda). Each of them has 
huge experience in programming and gathering business requirements from customers.
It would be best if you read now [the third post](https://mrpicky.dev/this-could-be-the-biggest-post-about-big-picture-event-storming-ever-and-with-examples/) 
of the series to see how we ran the BPES on this domain.
We ended up with something like this:
![Big Picture Event Storming](https://mrpicky.dev/wp-content/uploads/2021/04/BPES_02_timeline-scaled.jpg)

### Process Level Event Storming (PLES)
Here we need to climb down and model sub-processes that will address our business requirements and issues. 
Back on the BPES workshop, we could notice some smaller, autonomic sub-processes within the whole process. Now we can 
focus on each of them and take care of details. PLES gives us a few additional elements that will help us in this job. 
Those elements are: read model, command, system, policy.
To get more details about the PLES you need to wait a bit as the fourth post is in review at the moment.

### Design Level Event Storming (DLES)
It's the cherry on top. You may not believe it, but we are going to... design here. We are going to propose some models 
that will support processes identified during PLES. You will find all details about how I did it in the future, fifth post. 
Subscribe to my [newsletter](https://mrpicky.dev/loot/) to not miss it!

## Java fanboy programming in Ruby?
Even though I'm a Java fanboy, I decided to implement this project in Ruby. Currently, I'm writing the first post about 
the implementation where I describe more details and motivation behind it. When it's ready, I will, of course, update 
the README, and I will encourage you to read it as I will also explain there some concepts like CQRS and Event Sourcing.
To sum it up, I find the [Rails Event Store](https://railseventstore.org/) very easy to use, and it helps to focus on 
the business logic and not on the glue code for commands and events. I also know [Arkency's](https://arkency.com/) 
approach to DDD, and it resonates with me. Last but not least, Ruby was on my to-do list quite long, so here I am.

## Have fun and collaborate!
Now, browse the code, run some tests, play with it! If you find anything that you would do in a different way, just fork
the repo, do it, and don't forget to share it with [me](https://twitter.com/StolarczykT). Found a bug? Fix it! :)