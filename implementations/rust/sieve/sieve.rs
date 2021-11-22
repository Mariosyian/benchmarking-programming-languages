/**
 * This is an example program to encapsulate everything I have learned in Rust thus
 * far. It will be heavilly and unnecessarilly commented as this is more of a log
 * rather than an program meant to be executed.
 * 
 * author: Marios Yiannakou
 */
// Import libraries.
use std::cmp::Ordering;

/**
 * Function `main` in Rust has the same meaning as in Java. This is the first function
 * that is executed once a Rust executable is loaded.
 * 
 * A function is created by the keyword `fn`, then normal convention.
 * Rust does not use tabs for indentation, but 4 spaces.
 */
 fn main() {
    // There are three types of variables
    //   Immutable variables
    let x = 0;
    //   Mutable variables
    let mut y = 0;
    //   Constants -- MUST be typed. Can not be calculated (https://doc.rust-lang.org/reference/const_eval.html).
    //                MUST be capitalised and snake case.
    const Z: u32 = 0;

    // This is a call to a macro. Notice the '!'. This is not the same as a function
    //   call apparently ..
    println!("Hello world!");

    // You can create an inner scope within a function .. for some reason
    {
        // Redefining a variable with the `let` keyword is called shadowing.
        // It allows a user to redefine an immutable variable and even change
        //   it's type.
        let x = "HeHe";

        // You can also print with placeholders
        println!("The value of x, y, and z are {}, {}, and {}", x, y, Z);
        // Whereas a mutable object can be reassigned a value, but it can not be
        //   shadowed. The assignement also carries to the outer scope as it is
        //   not a new variable.
        y = 5;
    }
    
    // The change created in the inner scope does not apply outside of it.
    println!("The value of x, y, and z are {}, {}, and {}", x, y, Z);

    // Loops
    //   Infinite loop
    loop {
        // Ask for user input from the stdin stream.
        let mut input : String = String::new();
        // Can also use the full path of a library's function without importing it.
        println!("Enter a value:");
        std::io::stdin()
            // Provide the reference to a mutable object.
            .read_line(&mut input)
            // Expect line means in case of an error print the given string.
            //   But it still crashes, this is not error handling!!!
            .expect("Failed to read line");
            /*
             * `expect()` returns an object of type `Result`, an enumeration object
             * that can be broken down into it's two components: Ok() and Err().
             */
            let input: u32 = match input.trim().parse() {
                Ok(num) => num,
                Err(_) => continue,
            };

        // Compare numbers?
        match input.cmp(&Z) {
            Ordering::Less => println!("{} is smaller than Z.", input),
            Ordering::Greater => println!("{} is greater than Z.", input),
            Ordering::Equal => {
                println!("{} is equal to Z!\nBye bye!", input);
                break
            },
        }
    }
}