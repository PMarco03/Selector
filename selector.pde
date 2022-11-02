/*
1) open the file with all engines an the paths; 
2) find the first "." and isolate the name of the engine; 
3) show the name in the list; 
4) once selected, copy and paste the path of the engine in main.mr; 
5) open the file of the engine and look for the string "wires wires()"; 
6) from it, search going back a string that starts with "public node"; 
7) from that string, search the first "e" (the "e" of "node" 
   and search the first "{"; 
8) substring and keep just the name of the node; 
9) copy and paste the name of the node in main.mr
*/
import controlP5.*; //lib for the gui
import java.util.*; //lib for arraylist
ControlP5 cp5; //object used in gui
String err = "";
boolean exit = false; //if true, the program will close
String[] lib; //array used to save the lines of "main.mr"
ArrayList <String> engines;
int startfrom = 0; //the number of line skipped during the check of engines
void setup(){ //functions executed just once
  PFont font = createFont("arial",30);
  cp5 = new ControlP5(this); 
  engines = new ArrayList<String>();
  size(500,400); //size of the window
  lib = loadStrings("engines.mr"); //save all the lines of "main.mr" in the array lib
  boolean stop = false; 
  int ii = 0;
  //read all the lines and stop when "engines" is found
  //this is used to skip the line for themes and everythink that is not
  //an engine path
  while(stop == false && ii<lib.length){
    if(lib[ii].contains("engines")){
      startfrom = ii;
      stop = true;
      println(lib[ii]);
    }
    if(ii==lib.length) exit();
    ii++;
  }
  String nlib;
  int ch;
  //read all engines import and isolate the name of the file so it can be 
  //shown in the gui
  for(int i = startfrom; i<lib.length;i++){
    ch = lib[i].indexOf('.');
    if(ch!=-1){
      nlib=lib[i].substring(lib[i].lastIndexOf('/')+1,ch);
      engines.add(nlib);
    }
  }
  //this is the gui with its parameters
  cp5.addScrollableList("Engines")
     .setPosition(0, 0)
     .setSize(500, 400)
     .setBarHeight(50)
     .setItemHeight(50)
     .setFont(font)
     .addItems(engines)
     ;
  
}
void draw(){
  background(0);
  textSize(30);
  fill(255,0,0);
  text(err,0,100);

 }
//this function is called when the user selects an engine on the gui
//once selected, the function gets the index of the engine selected
//n is the index of the selected engine
void Engines(int n){
  //println(engines.get(n));
  //using the index, it keeps just the path without "import"
  String path = "../"+lib[n+startfrom].substring(lib[n+startfrom].indexOf('"')+1,lib[n+startfrom].lastIndexOf('"'));
  ArrayList <String> nfile = new ArrayList<String>();
  File f = dataFile("../"+path);
  String fpath = f.getPath();
  println(fpath);
  if(!f.isFile()){
    err="engine not found";
    return;
  }
  String fileEngine[]= loadStrings(path);
 
  
  String node = finder("alias output __out: engine;",fileEngine);
  if(node == "") {
   err= "Couldn't find Node name";
   return;
  }
  String veh = finder("alias output __out: vehicle;",fileEngine);
  if(veh!="") veh="set_vehicle("+veh+"())";
  String tran = finder("transmission(",fileEngine);
  if(tran!="") tran="set_transmission("+tran+"())";
 
  nfile.add(lib[0]);
  nfile.add(lib[1]);
  nfile.add(lib[n+startfrom]);
  for(int i = 0; i<lib.length; i++){
    if(lib[i].contains("set_engine(")){
       println(lib[i]);
       nfile.add("set_engine("+node+"())");
        nfile.add(veh);
        nfile.add(tran);
      }
    }
    String writer [] = new String[nfile.size()];
    for(int i = 0; i<nfile.size(); i++)writer[i] = nfile.get(i);
  saveStrings("../main.mr", writer);
  exit();
  text("Done",0,0);
 
}
String finder (String tofind, String array[]){
  int ii = 0;
  String result;
  while(ii<array.length && !array[ii].contains(tofind))ii++;
  if(ii==array.length) return "";
  while(ii>=0 && !array[ii].contains("public node"))ii--;
  if(ii<0) return "";
  int e = array[ii].indexOf('e');
  println(e);
  int graph = array[ii].indexOf('{');
  println(graph);
  result=array[ii].substring(e+2,graph);
  return result;
}
