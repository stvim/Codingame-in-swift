# Codingame Solutions

This project is an Xcode workspace containing multiple targets, my personal work to solve specific puzzles, bot battles, and challenges from [codingame.com](https://www.codingame.com).

## Project Overview

This repository is organized into multiple targets, each representing a unique solution or project. The main goal is to use Swift to solve coding puzzles and participate in bot battles and other competitions available on Codingame.

### Features:
- Multiple Xcode targets for different puzzles and challenges.
- **CodingameCommon** mini-framework for enhancing the development and testing process (see details below).
- Swift as the main programming language.
- Solutions organized by category and difficulty.

### CodingameCommon: A Supporting Mini Framework

The **CodingameCommon** target is a mini-framework designed to assist in the development of solutions for Codingame puzzles. It provides several helpful utilities that streamline input/output handling, testing, and debugging during development.

### Key Features of `CodingameCommon`:
- **Input/Output Management**: Automatically stores and prints all inputs and outputs during a process, allowing you to review the flow of data easily.
- **File-Based Input**: Supports the use of external input data files, making it easier to test solutions with predefined inputs.
- **Automatic Testing**: You can run automatic tests using input files to simulate various scenarios, ensuring your solution behaves correctly under different conditions.
- **Interactive Command Line Mode**: Allows you to execute the code in an interactive mode, functioning as a command-line tool for rapid development and testing.

### Understanding the interoperability between Xcode & codingame.com
Each new Codingame solution code file should start with the HEADER block found in the CodingameTemplate/Exercice1 file. 
This header ensures that the code remains interoperable between the Xcode environment and the Codingame web interface. 
**The CodingameCommon framework will be imported when Xcode runs your code, the HEADER block will be executed instead in codingame.com engine.**

When copying your solution from Xcode to the Codingame platform, all you need to do is uncomment the main() execution line at the bottom of the file to make it work seamlessly in the Codingame web interface.

## Prerequisites

- macOS with [Xcode](https://developer.apple.com/xcode/) installed.
- Basic knowledge of Swift programming and the Xcode environment.
- An active account on [Codingame](https://www.codingame.com) to test and submit solutions.


## Usage

**Import the Framework**: Include the `CodingameCommon` target in any Codingame puzzle target.
**Use Input Files Data (scenarios) or Interactive mode to test your code**: 
- You can specify input files to simulate various test cases instead of manual input, enhancing the ability to test and debug complex problems, and run many tests at once.
- Or the framework provides utilities to run your solution interactively from the command line, mimicking the Codingame environment for on-the-fly testing/debugging.

### Interactive Mode
The framework provides utilities to run your solution interactively from the command line, mimicking the Codingame environment for easier debugging.
- Create a new target as a **CommandLine Tool**
- Insert "Dialog.mode = .Interactive" in the firsts lines of your main() function
- Uncomment main() on the last line
- Run the target/scheme in Debug mode (Xcode)

### Scenario Mode
- Create a new target with UnitTests
- Create unit tests following the CodingameTemplateTests example. Create a text file for inputs and write a testing function as follows :

      let dataFilenames = ["", "Exercice1Data01"]

      func testData01() throws {
        let bundle = Bundle(for: Exercice1Tests.self)
        let fileUrl = bundle.url(forResource: dataFilenames[1], withExtension: "")!
        
        Dialog.mode = DialogMode.Scenario(gameData: GameData(inputDataFile: fileUrl))
        main()
      }
- Run the target/scheme in Test mode (Xcode) 


## Contributing

Contributions are welcome! Feel free to submit pull requests for new puzzles or improvements to existing solutions. Please follow the guidelines below when contributing:

- Fork the repository.
- Create a new branch (feature-new-puzzle).
- Commit your changes.
- Push your branch and submit a pull request.


## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or suggestions, feel free to reach out via GitHub issues.
