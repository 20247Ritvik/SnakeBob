import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_bob/blank_pixel.dart';
import 'package:snake_bob/food_pixel.dart';
import 'package:snake_bob/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //grid dimensions
  int rowSize = 10;
  int totalNumberOfSquare = 100;

  bool gamHasStarted = false;
  // User score
  int currentScore = 0;

  // snake Position
  List<int> snakePos = [0, 1, 2];

  // snake Direction is Initially to the right

  var currentDirection = snake_Direction.RIGHT;

  //food position
  int foodPos = 55;

  // start the game
  void startGame() {
    gamHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving...
        moveSnake();

        // check if the game is over
        if(gameOver()){
          timer.cancel();

          // ---Dialog---  display a message to the user
          showDialog(
            barrierDismissible: false,
              context: context,
              builder: (context) {
            return AlertDialog(
                title: Text("Game Over"),
              content: Column(
                children: [
                  Text("Your current score is:"+ currentScore.toString()),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter name"),
                  )
                ],
              ),
              actions: [MaterialButton(
                onPressed:(){
                Navigator.pop(context);
                submitScore();
                newGame();
                } ,
                child: Text("Submit"),
                color: Colors.pink,
              )],
            );
          });
        }
         });
    });
  }

  void submitScore(){
    // add data to firebase


  }

  void newGame(){
    setState(() {
      snakePos =[
        0,1,2
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gamHasStarted = false;
      currentScore=0;
    });
  }



  void eatfood(){
    // score increase every time we eat food...
    currentScore++;
    // making sure the new food is not where the snake is...
    while(snakePos.contains(foodPos)){
      foodPos = Random().nextInt(totalNumberOfSquare);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //add a head
          //if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            // add a new head
            snakePos.add(snakePos.last + 1);
           }
        }
        break;

      case snake_Direction.LEFT:
        {
          //if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            // add a new head
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          // add a new head
          if(snakePos.last < rowSize){
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquare);
          }else{
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          // add a new head
          if(snakePos.last + rowSize > totalNumberOfSquare){
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquare);
          }else{
            snakePos.add(snakePos.last + rowSize);
          }
          }
        break;
      default:
    }

// snake is eating food

    if(snakePos.last == foodPos){
      eatfood();
    }
    else{
      // remove the tail
      snakePos.removeAt(0);
    }
  }

  // game over
  bool gameOver(){
    // the game is over when the snake runs into itself
    // this occurs when there is a duplicate position in the snakePos list

    // this list is the body of the snake (no head)

    List<int> bodySnake = snakePos.sublist(0, snakePos.length-1);

    if (bodySnake.contains(snakePos.last)){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // high score
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // user current score
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Current Score", style: TextStyle(fontSize: 20, color: Colors.white),),
                      Text(
                          currentScore.toString(),
                      style: TextStyle(fontSize: 36, color: Colors.white),),
                    ],
                  ),

              // high score
              Text("HighScore..", style: TextStyle(fontSize: 20,color: Colors.white),)

                ],
          ),
          ),

          // game grid
          Expanded(
              flex:3,
              child: GestureDetector(
                onVerticalDragUpdate: (details){
                  if(details.delta.dy > 0 &&
                      currentDirection!= snake_Direction.UP){
                    currentDirection = snake_Direction.DOWN;
                  }
                  else if(details.delta.dy < 0 &&
                      currentDirection!= snake_Direction.DOWN){
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details){
                  if(details.delta.dx > 0&&
                      currentDirection!= snake_Direction.LEFT){
                    currentDirection = snake_Direction.RIGHT;
                  }else if(details.delta.dx < 0&&
                      currentDirection!= snake_Direction.RIGHT){
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                    itemCount: 100,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                  itemBuilder: (context, index){
                      if(snakePos.contains(index)){
                        return const SnakePixel();
                      }
                      else if(foodPos==index){
                        return const FoodPixel();
                      }
                      else{
                        return const BlankPixel();
                      }}
                  ),
              ),),


          //play button
          Expanded(child: Container(
            child: Center(
              child: MaterialButton(
                child: Text("PLAY"),
                color: gamHasStarted ? Colors.grey:Colors.pink,
                onPressed: gamHasStarted ?() {} : startGame,
              ),
            ),
          )
          ),
        ],
      ),
    );
  }
}

