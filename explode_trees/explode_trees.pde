/*
  Exploding Trees
  ---------------
  This code will procedurally generate simple trees.
  
  -Click to generate more trees
  -Press '1' to cause each tree to "explode" in a very interesting animation.
  -Press '2' to make each tree to "curl up" like a tumble weed
  
  It is recommended not to switch between curling and exploding as trees may not stay on screen.
  It is also not recommended to spawn more than a handful of trees on screen at a time as this may cause significant lag.
  
  written by Adrian Margel, Spring 2016
*/



//if the trees are exploding
boolean explode=false;
//if the trees are curling
boolean curl=false;
//the list of placed trees
ArrayList <Tree> forest=new ArrayList<Tree>();

//simple vector class for the branch point
class BPoint {
  float x;
  float y;
  BPoint(float tempX, float tempY) {
    x=tempX;
    y=tempY;
  }
}


class Tree {

  //depth the tree will generate from
  int size=15;
  //number of branches that will spawn from each split
  int split=2;
  //chance of a branch being shorter than the set depth/size
  float chance=1500;
  //randomness in generation
  float noise=0.2;

  //the range of how long branches are
  float branchMin=15;
  float branchMax=20;

  int currentBId=1;

  //start pos of the tree
  BPoint seedPos;
  //all branches
  ArrayList<Branch> branches=new ArrayList<Branch>();

  //create a tree at a postion
  Tree(BPoint tempseed) {
    seedPos=tempseed;
  }

  //spawns tree/ grows all the branches
  void grow() {
    //spawn trunk
    if (branches.size()==0) {
      branches.add(new Branch(currentBId, 0, PI, 100, seedPos));
      currentBId=1;
    }
    //grow the rest of the branches
    for (int i=branches.size()-1; i>=0; i--) {
      branches.get(i).age++;
      if (branches.get(i).splits<split) {
        if (random(0, currentBId/chance)<1) {
          branches.get(i).splits++;
          currentBId++;
          branches.get(i).point2=new BPoint(branches.get(i).point1.x+sin(branches.get(i).rot)*branches.get(i).bLength, 
            branches.get(i).point1.y+cos(branches.get(i).rot)*branches.get(i).bLength);
          branches.add(new Branch(currentBId, branches.get(i).id, branches.get(i).rot+random(-noise, noise)*PI, random(branchMin, branchMax), branches.get(i).point2));
        }
      }
    }
    //finish off generated branches
    for (int i=branches.size()-1; i>=0; i--) {
      branches.get(i).point2=new BPoint(branches.get(i).point1.x+sin(branches.get(i).rot)*branches.get(i).bLength, 
        branches.get(i).point1.y+cos(branches.get(i).rot)*branches.get(i).bLength);
    }
  }
  
  //explodes tree
  void explode() {
    //move the start of the branch to the end position
    for (int i=0; i<branches.size(); i++) {
      branches.get(i).point1=branches.get(i).point2;
      branches.get(i).point2=new BPoint(branches.get(i).point1.x+sin(branches.get(i).rot)*branches.get(i).bLength, 
        branches.get(i).point1.y+cos(branches.get(i).rot)*branches.get(i).bLength);
    }
  }
  
  //updates tree to make sure all branches are connected
  void update(Branch tempBranch) {
    for (int j=branches.size()-1; j>=0; j--) {
      if (branches.get(j).id==tempBranch.conId) {
        tempBranch.point1=branches.get(j).point2;
      }
    }
    tempBranch.point2=new BPoint(tempBranch.point1.x+sin(tempBranch.rot)*tempBranch.bLength, 
      tempBranch.point1.y+cos(tempBranch.rot)*tempBranch.bLength);
    for (int j=branches.size()-1; j>=0; j--) {
      if (branches.get(j).conId==tempBranch.id) {
        update(branches.get(j));
      }
    }
  }
  //display tree
  void display() {
    for (int i=0; i<branches.size(); i++) {
      //stroke(0,255/sqrt(sqrt(branches.size())));
      stroke(0);
      strokeWeight(branches.get(i).age/4);
      line(branches.get(i).point1.x, branches.get(i).point1.y, branches.get(i).point2.x, branches.get(i).point2.y);
      if (branches.get(i).splits==0) {
        noStroke();
        fill(0, 10);
        //ellipse(branches.get(i).point2.x,branches.get(i).point2.y,size-branches.get(i).age,size-branches.get(i).age);
      }
    }
  }
}
class Branch {
  int age;
  int splits;
  int id;
  int conId;
  float rot;
  float bLength;
  BPoint point1=new BPoint(0, 0);
  BPoint point2=new BPoint(0, 0);
  Branch(int tempid, int tempconId, float temprot, float tempbLength, BPoint temppoint1) {
    id=tempid;
    conId=tempconId;
    rot=temprot;
    bLength=tempbLength;
    point1=temppoint1;
  }
}
void setup() {
  size(1200, 800);
}
void draw() {
  background(255);
  for (int i=0; i<forest.size(); i++) {
    if (explode) {
      //explode trees
      for (int j=0; j<forest.get(i).branches.size(); j++) {
        //slightly rotate branches to make them fly in a loop
        forest.get(i).branches.get(j).rot+=-0.1;
      }
      forest.get(i).explode();
    } else if(curl) {
      //curl trees
      for (int j=0; j<forest.get(i).branches.size(); j++) {
        //rotate all branches at different speeds.
        forest.get(i).branches.get(j).rot+=0.01*forest.get(i).branches.get(j).age;
        //this will slow the rotation of the trunk
        forest.get(i).branches.get(j).rot+=-0.2;
      }
      forest.get(i).update(forest.get(i).branches.get(0));
    }
    //display trees
    forest.get(i).display();
  }
}
void mousePressed() {
  //add a new tree
  forest.add(new Tree(new BPoint(mouseX, mouseY)));
  for (int i=0; i<forest.size(); i++) {
    if (forest.get(i).branches.size()<1) {
      for (int j=0; j<forest.get(i).size; j++) {
        forest.get(i).grow();
      }
    }
  }
}
void keyPressed() {
  //change between exploding and curling
  if (key=='1') {
    explode=true;
    curl=false;
  }
  if (key=='2') {
    explode=false;
    curl=true;
  }
}
