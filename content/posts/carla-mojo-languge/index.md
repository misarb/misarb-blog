+++
title = "Carla and mojo"
date = 2023-10-22
author = "BOULBALAH Lahcen"
tags = ["mojo","carla"]
keywords = ["carla", "mojo programming"]
description = "Connecting carla using mojo as an API insted of using python"
showFullContent = false
+++
# Table of contents

1. [Introduction](#introduction)
2. [Brief introducation about mojo](#brief-introducation-about-mojo)
3. [Carla Api using Python ](#carla-api-using-python)
4. [Connecting carla using Mojo](#connecting-carla-using-mojo)
5. [Conclusion](#conclusion)
6. [Resources](#resources)



## Introduction

- This year, in my role as an R&D software engineer, I've been using the CARLA simulator to test a range of controller algorithms. I mainly employed the Python API and ROS-Bridge to establish connections with the CARLA server. While working on this, I began considering the feasibility of adopting the Mojo language as a potential substitute for the Python API, with the aim of harnessing Mojo's inherent speed and advantages.

**Disclaimer**: This post is not intended as a Mojo tutorial; it focuses on exploring a *potential use case of Mojo with the CARLA simulator*. If you're interested in learning more about Mojo, be sure to check out the resources section, where I'll include some useful links.

## Brief introducation about mojo

  `Mojo` is a programming language that seamlessly marries the performance and control typically associated with system languages like `C++` and `Rust` with the flexibility and ease of use found in dynamic languages such as `Python`. This unique blend of attributes positions **Mojo as a powerful choice for constructing high-performance systems and a compelling option for AI development**.

The inception of `Mojo` can be credited to Modular, a company with a vision to democratize AI programming. Mojo's design is rooted in the idea of making AI development more accessible to a broader spectrum of developers. By merging the performance capabilities of `C` with the user-friendliness of Python, Modular aims to foster AI advancement, providing a platform suitable for both aspiring and seasoned engineers.

 Example of mojo code 
```python
  fn pow(base: Int, exp: Int = 2) -> Int:
      return base ** exp

  # Uses default value for `exp`
  z = pow(3)
  print(z) #output 9
```
In `Mojo`, you have the ability to specify the types of your variables. Notably, the `Int` type in `Mojo`, with a capital `I` differs from `Python`'s `int`. While Python's `int` can manage large numbers and offers additional features like object identity checks, it can introduce some performance overhead. In contrast, Mojo's `Int` is purpose-built for simplicity and speed, optimized to efficiently leverage your computer's hardware.

## Carla Api using Python 

CARLA is a versatile simulator that provides an environment for algorithm testing, custom map creation, and the evaluation of Advanced Driver Assistance Systems (ADAS) functionality. To connect to CARLA, developers make use of an API. By creating a Python script, you can establish a connection with the CARLA server, enabling you to send commands for vehicle control within the simulator and retrieve data from sensors and other sources. Here's how you can achieve this with Python

```python
import carla

# Define the CARLA server's IP and port
carla_host = "localhost"
carla_port = 2000

# Create a connection to the CARLA simulator
client = carla.Client(carla_host, carla_port)
client.set_timeout(2.0)  # Set a timeout for the connection

try:
    # Load a CARLA world map
    world = client.get_world()

finally:
    # Clean up and disconnect from the simulator
    client.disconnect()

```
we specify the host where the CARLA server is running. If you are running the CARLA server on a different host, replace `localhost` with the IP address of the server where you have launched CARLA. Once connected to the server, you can easily spawn vehicles and control them, like in the example above.

```python
    # Get a blueprint for a vehicle (e.g., a Tesla Model 3)
    blueprint_library = world.get_blueprint_library()
    vehicle_bp = blueprint_library.filter("model3")[0]

    # Set the spawn location for the vehicle
    #you can change the x , y and z for diffrent position in the map
    spawn_point = carla.Transform(carla.Location(x=100, y=100, z=0.69), carla.Rotation())

    # Spawn the vehicle
    vehicle = world.spawn_actor(vehicle_bp, spawn_point)

    # Control the vehicle to move forward
    vehicle.apply_control(carla.VehicleControl(throttle=1.0, steer=0.0))

    # Keep the vehicle moving for a few seconds
    carla.utils.npc_vehicle(vehicle, max(1, 10))

```

## Connecting carla using Mojo


Here, I will demonstrate how to connect to the CARLA server using the `Mojo language`. In `Mojo`, we have the capability to import and utilize `Python` modules. However, it's important to note that not all Python modules can be seamlessly used in Mojo.

To import a Python module in Mojo, you can simply use the following syntax, which is similar to importing a Python library in Python:

```python
from python import Python as py
```
Now, if you need to import a library like `numpy`, you can do so using the `import_module` methode. It's essential to encapsulate this within a function and specify a raises clause. You might wonder why this is necessary. The reason is that certain modules can potentially raise errors, and Mojo needs to handle these situations. Therefore, to ensure your code compiles correctly, follow the example below:

```python
from python import Python as py
fn myModule() raises:
    let np = py.import_module("numpy")    

```
This structure ensures that any potential errors raised by the module are appropriately managed by Mojo, allowing your code to compile without issues.

Now, we will employ the same approach to establish a connection with CARLA and take control of a vehicle by sending commands to a spawned vehicle. Specifically, we will send the commands `steer: 0.0` and `throttle: 0.3`. Our objective is to have the vehicle move in a straight line.

```python
from python import Python as py

  fn main() raises:
      print("Welcom to the first Mojo Carla call")
      let carla = py.import_module("carla")
      let random = py.import_module("random")
      let client = carla.Client("localhost", 2000)
      let world = client.get_world()
      let blueprint_library = world.get_blueprint_library()
      let model_3 = blueprint_library.filter("vehicle.audi.a2")[0]
      let spawan_point = random.choice(world.get_map().get_spawn_points())
      let vehicle = world.spawn_actor(model_3, spawan_point)
      let control = carla.VehicleControl()
      print(vehicle)

      while True:
          control.steer = 0.0
          control.throttle = 0.3
          control.brake = 0.0
          control.hand_brake = False
          # send control to the vehicle in carla
          _ = vehicle.apply_control(control)
          print("steer = ", control.steer)
        client.set_timeout(2.0)

```
To execute the code below, please follow these steps:

1- Place the code in the `pythonAPI` folder of your CARLA installation.       
2- Start your CARLA server.   
3- Run the Mojo code using the following command:

```js
  mojo file_name.mojo
```
Congratulations! You've successfully run the MojoAPI for CARLA.

## Conclusion
 
- Mojo is a very interesting language, with immense potential. However, it's important to note that the community around Mojo is still relatively small.

- One of the most intriguing aspects is the prospect of witnessing substantial projects leverage Mojo with CARLA simulator, particularly when implementing Advanced Driver Assistance Systems (ADAS) functionality using AI. This combination allows developers to harness the power of the Mojo language for complex control algorithms, like Linear Model Predictive Control (Linear-MPC), which demand significant computational resources.

## Resources

In this section I tried to compile a bunch of links that might help when trying
to learn/understand the things mentioned above, feel free to read at your own
pace.
unfortuntly i don't find any resource related to carla and mojo use case i hope it will be in the future

- [Mojo doc](https://docs.modular.com/mojo/)
- [Carla doc](https://carla.readthedocs.io/en/0.9.14/)
- [ROSdoc](https://docs.ros.org/en/foxy/index.html)



