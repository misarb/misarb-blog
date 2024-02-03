+++
title = "Hands-On Rust Threads: A Journey from Basics to Real-World Examples"
date = 2024-02-01
author = "BOULBALAH Lahcen"
tags = ["Rust","Thread","Safety"]
keywords = ["Rust", "Thread programming"]
description = "Explaining Rust Threads with Examples and Use Cases"
showFullContent = false
+++
# Table of contents

1. [Introduction](#introduction)
2. [ what is Threads](#whats-threads)
3. [ Creation of Threads in Rust](#Creating-of-Thread-in-Rust)
4. [ Thread Communication](#Thread-Communication)
5. [ Practical Examples](#practical-examples)
6. [ Performance Benefits](#performance-benefits)
7. [ Use Cases](#use-cases)
8. [ Conclusion](#conclusion)


## Introduction

In the fast-evolving landscape of programming languages, Rust has emerged as a robust and efficient choice for system-level programming, known for its focus on memory safety without sacrificing performance. One of the key features that contribute to Rust's prowess is its threading model, which enables developers to harness the power of parallelism in their applications.

In today's blog post, we delve into the world of Rust threads, unraveling the intricacies of how they function and exploring practical examples of how they can be employed to enhance the performance of your code. Whether you are a seasoned Rust developer or someone just starting to explore the language, understanding the fundamentals of Rust threads is crucial for unlocking the full potential of concurrent programming.

## what's Threads

***Thread:*** An execution unit is comprised of distinct components, including its own program counter, a stack, and a set of registers. The program counter primarily manages the instruction to be executed next, while the registers mainly store the unit's current working variables. Additionally, the stack primarily retains the historical record of execution.

Threads serve as a popular method to enhance application performance through parallelism. They represent a software approach aimed at optimizing operating system performance by reducing the overhead associated with threads, akin to classical processes.

The CPU seamlessly switches between threads, creating the illusion of parallel execution. Each thread possesses independent resources for process execution, enabling the parallel execution of multiple processes by increasing the number of threads.

It's crucial to emphasize that each thread is associated with precisely one process, and outside a process, no threads exist. Threads individually represent the flow of control. Successful implementations of threads are observed in network servers and web servers, where they contribute to efficient parallel execution. Threads offer a solid foundation for running applications concurrently on shared-memory multiprocessors.

The diagram below illustrates the operation of both single-threaded and multithreaded processes:

{{< figure src="./images/rust-thread.png" alt="Rust thread" position="center" style="border-radius: 8px;" caption="Single thread vs MultiThread" captionPosition="center" captionStyle="color: white;" >}} 


## Creating a Thread in Rust

In Rust we can crate a thread using `thread::spawn()` function from `std` module , the spawn methode take a closuer as an arguement ,a closure is essentially an anonymous function that can capture variables from its surrounding scope, creating a self-contained unit of code that can be executed independently.

``` Rust
    thread::spawn(||{
        // Code to be executed in the new thread
    })

```

`Thread Creation:` thread::spawn creates a new operating system thread, allowing the closure to run concurrently with the main thread.

`Closure Execution:` The provided closure contains the code that will be executed in the new thread.

``` Rust 
    use std::thread;

    fn main() {
        let handle = thread::spawn(|| {
            // Code to be executed in the new thread
        });

        // ..... Main thread continues its work .....

        // Wait for the spawned thread to finish
        handle.join().unwrap();
    }

```
In concurrent programming, managing threads involves more than just launching them. The concept of a **thread handle** becomes crucial for interacting with and controlling the behavior of the spawned thread.

***Importance of the `Handle` Variable***

`Thread Control:` The handle variable returned by `thread::spawn` is a handle to the newly created thread. It allows the main thread to interact with the spawned thread's execution.
`Waiting for Completion:` One common use of the handle is to wait for the spawned thread to complete its execution. This is achieved through the `join` method on the handle, which effectively pauses the main thread until the spawned thread finishes.


``` Rust
    use std::thread;
    use std::time::Duration;

    fn counter() {
        for i in 0..5 {
            println!("{} Hello from my thread", i);
            thread::sleep(Duration::from_secs(1));
        }
    }

    fn main() {
        // Create a thread using thread::spawn() function
        let handle = thread::spawn(|| {
            // Code to be executed in the thread
            counter();
        });

        for i in 0..5 {
            println!("{} Hello from the Main thread", i);
            thread::sleep(Duration::from_secs(1));
        }

        // Wait for the spawned thread to finish
        handle.join().unwrap();
    }
    
```
OUTPUT :

``` 
    0 Hello from the Main thread
    0 Hello from my thread
    1 Hello from the Main thread
    1 Hello from my thread
    2 Hello from the Main thread
    2 Hello from my thread
    3 Hello from the Main thread
    3 Hello from my thread
    4 Hello from the Main thread
    4 Hello from my thread
```


## Thread Communication

Thread communication is a critical aspect of concurrent programming, enabling threads to exchange data and coordinate their activities. In Rust, communication between threads is facilitated by various mechanisms that ensure safe and synchronized interactions.

1- Message Passing

{{< figure src="./images/mpsc-general.png" alt="mpsc" position="center" style="border-radius: 8px;" caption="mpsc: Multi-producer Single Consumer" captionPosition="center" captionStyle="color: white;" >}} 

 * Channels :
 Rust provides channels, a communication primitive that allows threads to send messages to each other. A channel consists of a sender and a receiver. The sender can transmit data to the receiver, establishing a simple and effective means of communication.



Each channel has two ends — sender and receiver. It is also unidirectional — the messages can only be passed from the sender to the receiver, never other way around. What is specific to MPSC channels, is that there can be many senders (message producers), but there’s always only one receiver (consumer).

{{< figure src="./images/mpsc-rust-example.png" alt="mpsc" position="center" style="border-radius: 8px;with=956 ;height=200" caption="Rust Example for mpsc" captionPosition="center" captionStyle="color: white;" >}} 

``` Rust 
    ususe std::thread;
    use std::sync::mpsc;

    fn main() {
        let (sender, receiver) = mpsc::channel();

        thread::spawn(move || {
            sender.send("misarb").unwrap();
            sender.send("lboulbalah").unwrap();
            sender.send("hello Rust").unwrap();
        });

        // Main thread receiving the messages
        for msg in receiver {
            println!("{}", msg);
        }
    }

```

## Practical Examples

## Use Cases

## Conclusion