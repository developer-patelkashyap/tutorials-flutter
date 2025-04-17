/// Fundamentals

// In-line Comment

/*
    Multi-line Comment
*/

/// Documentation

/// Hello World Program

// main() {
//     print("Hello, World!");
// }

/// Importing Pkg and Taking User Input

import 'dart:io';

main() {
    stdout.writeln('What is your name?');
    var name = stdin.readLineSync();
    print('My name is $name.');
}
