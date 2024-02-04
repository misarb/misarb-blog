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
3. [ Creating a Thread in Rust](#creating-a-thread-in-rust)
4. [ Thread Communication](#thread-communication)
5. [ Use Case](#use-case)
6. [ Conclusion](#conclusion)


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

 * Channels :
 Rust provides channels, a communication primitive that allows threads to send messages to each other. A channel consists of a sender and a receiver. The sender can transmit data to the receiver, establishing a simple and effective means of communication.

{{< figure src="./images/mpsc-general.png" alt="mpsc" position="center" style="border-radius: 8px;" caption="mpsc: Multi-Producer Single Consumer" captionPosition="center" captionStyle="color: white;" >}} 




Each channel has two ends — sender and receiver. It is also unidirectional the messages can only be passed from the sender to the receiver, never other way around. What is specific to MPSC channels, is that there can be many senders **message producers**, but there’s always only one receiver **consumer**.

Let's see how we can apply this in a Rust code. We will follow the figure below, where we have three messages in a spawned thread and send them from one thread to another—the main thread—to establish communication between these two threads. 

{{< figure src="./images/mpsc-rust-example.png" alt="mpsc" position="center" style="border-radius: 8px;with=956 ;height=200" caption="Rust Example for mpsc" captionPosition="center" captionStyle="color: white;" >}} 

``` Rust 
    use std::thread;
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
OUTPUT :
``` 
    misarb
    lboulbalah
    hello Rust
```
2- Mutual Exclusion (Mutex)

Mutex is an abbreviation for **Mutual Exclusion** It is a synchronization primitive used in concurrent programming to enforce exclusive access to a shared resource or data. 
It's provide a mechanism for mutually excluding multiple threads from accessing a critical section of code simultaneously.


{{< figure src="./images/mutex.png" alt="mpsc" position="center" style="border-radius: 8px;with=956 ;height=200" caption="Mutex: Mutual Exclusion" captionPosition="center" captionStyle="color: white;" >}} 

In Rust, the `Mutex` type is part of the standard library and is implemented as `std::sync::Mutex` . It allows threads to **`lock`** and **`unlock`** access to shared data, ensuring that only one thread can modify the data at a time, preventing data races and maintaining data integrity.

``` Rust
    use std::thread;
    use std::sync::{Arc, Mutex};

    fn main() {
            // shared counter with a Mutex
            let counter = Arc::new(Mutex::new(0));

            // vector to store thread handles
            let mut handles = vec![];

            // Spawning multiple threads to increment the counter
            for _ in 0..5 {
                let counter = Arc::clone(&counter);
                let handle = thread::spawn(move || {
                    // Acquiring the lock to modify the shared data
                    let mut data = counter.lock().unwrap();
                    *data += 1;
                });
                handles.push(handle);
            }

            // Waiting for all threads to finish
            for handle in handles {
                handle.join().unwrap();
            }

            // Accessing the final value of the shared counter
            println!("Counter: {}", *counter.lock().unwrap());
        }

```
In this example, the `Mutex` ensures that only one thread at a time can modify the shared **counter**. The lock method is used to acquire the lock before accessing or modifying the shared data, and the lock is automatically released when the variable data goes out of scope, allowing other threads to acquire the lock.


## Use Case

So now let's merge all these concepts in a comprehensive example step by step. We'll create a struct named `Calc` with a field called `counter` of type `i32`. 
```Rust
    struct Calc {
        counter: i32,
    }

```
Next, we'll implement some methods for this struct to increment the counter and display its state

```Rust
    // Implement methods for the Calc struct
    impl Calc {
        // Constructor method to create a new Calc instance with an initial counter value of 0
        fn new() -> Self {
            Self { counter: 0 }
        }

        // Method to increment the counter
        fn increment_counter(&mut self) {
            self.counter += 1;
        }

        // Method to display the current state of the counter
        fn show_counter(&self) {
            println!("Counter_State = {}", self.counter);
        }
    }
```

Now, let's use the struct and call its methods in the main thread without involving any spawned threads

```Rust
    fn main() {
        // Create a new Calc instance
        let mut calc = Calc::new();
        // Display the initial state of the counter
        calc.show_counter();
        // Increment the counter and display the updated state
        calc.increment_counter();
        calc.show_counter();
    }

```

OUTPUT :
``` 
   Counter_State = 0
   Counter_State = 1
```

and now let's creat a methode for the Calc struct to spawn a thread the run the incremetn_counter methdoe , for the firs impressin we can do something like this 

```Rust

    impl Calc {
        fn new() -> Self {
            Self { counter: 0 }
        }

        fn increment_counter(&mut self) {
            self.counter += 1;
        }

        fn spawn_thread(&mut self) {
            thread::spawn(move || {
                self.increment_counter();
            })
            .join()
            .unwrap();
        }

        fn show_counter(&self) {
            println!("Counter_State = {}", self.counter);
        }
    }

```

if we build the new implement code we will get this result 

OUTPUT

```
    error[E0521]: borrowed data escapes outside of associated function    
    16 |           fn spawn_thread(&mut self) {
    |                           ---------
    |                           |
    |                           `self` is a reference that is only valid in the associated function body
    |                           let's call the lifetime of this reference `'1`
    17 | /             thread::spawn(move || {
    18 | |                 self.increment_counter();
    19 | |             })
    | |              ^
    | |              |
    | |______________`self` escapes the associated function body here
    |                argument requires that `'1` must outlive `'static`

```

We've encountered an issue here when compiling the code. The error is related to ownership and lifetimes concerning the `self` reference within the closure passed to `thread::spawn`. The compiler points out that the closure is trying to take ownership of self, and it cannot guarantee that the reference will persist long enough to meet the 'static lifetime requirement of the spawned thread.

It might be complicated to try spawning a thread in this structure. A way to work around this is to create another struct. Let's see how we can solve that.

Let's create a struct called `InnerCalc` which has a field `calc` 

```Rust
    struct InnerCalc {
        calc: Arc<Mutex<Calc>>,
    } 

```

`calc:` This is a field within the InnerCalc struct. It holds an instance of Arc<Mutex<Calc>>.    
`Arc:` Stands for **Atomic Reference Counting,** and it is used to create a reference-counted smart pointer. It allows multiple references to the same data with automatic memory management.   
`Mutex:` Short for "Mutual Exclusion," [ Thread Communication](#thread-communication)    
`Calc:` This refers to the Calc struct that InnerCalc is intended to interact with.

Let's continue by adding methods to our new struct.

```Rust

    impl InnerCalc {
        // Method to create a new instance of InnerCalc
        fn new() -> Self {
            Self {
                calc: Arc::new(Mutex::new(Calc::new())),
            }
        }
        // Method to spawn a thread loop
        fn spawn_thread_counter(&self) {
            // Clone the Arc to ensure shared ownership
            let local_self = self.calc.clone();
            thread::spawn(move || {
                // Lock the Mutex to access and modify the shared Calc instance
                local_self.lock().unwrap().increment_counter();
            })
            .join()
            .unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    }
```

Here, we implement two methods:

` new:` This method creates a new instance of **InnerCalc**.
It initializes the calc field with a new instance of Arc<Mutex<Calc>>, where `Calc::new()` creates a new instance of the Calc struct.

`spawn_thread_counter:` This method is designed to spawn a new thread that increments the counter within the shared Calc instance. It clones the Arc (local_self) to ensure shared ownership between the main thread and the spawned thread. The spawned thread, through the closure, locks the Mutex to modify the shared Calc instance by calling increment_counter.

These methods showcase how `InnerCalc` can be instantiated and used to spawn threads that safely modify shared data (Calc) using the mechanisms of Arc and Mutex.

and her's the full Implmentation 

```Rust
    use std::{sync::Arc, sync::Mutex, thread, time::Duration};

    struct Calc {
        counter: i32,
    }

    // Implement methods for the Calc struct
    impl Calc {
        // Constructor method to create a new Calc instance with an initial counter value of 0
        fn new() -> Self {
            Self { counter: 0 }
        }

        // Method to increment the counter
        fn increment_counter(&mut self) {
            self.counter += 1;
        }

        // Method to display the current state of the counter
        fn show_counter(&self) {
            println!("Counter_State = {}", self.counter);
        }
    }

    struct InnerCalc {
        calc: Arc<Mutex<Calc>>,
    } 

    impl InnerCalc {
        // Method to create a new instance of InnerCalc
        fn new() -> Self {
            Self {
                calc: Arc::new(Mutex::new(Calc::new())),
            }
        }
        // Method to spawn a thread loop
        fn spawn_thread_counter(&self) {
            // Clone the Arc to ensure shared ownership
            let local_self = self.calc.clone();
            thread::spawn(move || {
                // Lock the Mutex to access and modify the shared Calc instance
                local_self.lock().unwrap().increment_counter();
            })
            .join()
            .unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    }

    fn main() {
        let inner = InnerCalc::new();
        inner.spawn_thread_counter();
        inner.calc.lock().unwrap().show_counter();
        
    }
```
OUTPUT :
``` 
   Counter_State = 1
```

## Conclusion

In conclusion, we've explored the concept of concurrent programming in Rust, focusing on the use of threads and synchronization mechanisms. The introduction of the `InnerCalc` struct, utilizing `Arc` and `Mutex`, demonstrated a practical approach to safely share and modify data across multiple threads. By creating a separation between the shared state and the methods responsible for thread interaction.   
As we wrap up, it's essential to continue the ongoing nature of learning in the dynamic Rust ecosystem. Continuously exploring new concepts