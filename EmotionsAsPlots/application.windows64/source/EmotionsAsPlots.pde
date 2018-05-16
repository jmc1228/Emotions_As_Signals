String[] boeing_data; 
String[] heartbeat_data; 
int plot_buffer_width = 600; 
int plot_buffer_height = 20; 
int t = 0; 
int t2 = 0; 
int gain_set = 100; 
float boeing_signal; 
float heartbeat_signal; 
Boolean play_audio = false;
float cap_charge = 0; 
int cap_charging = 0; 
float R = 1.0; 
float C = 1.0; 
ArrayList impulses = new ArrayList(); 
ArrayList cap_plot_points = new ArrayList(); 

import processing.sound.*; 
import controlP5.*; 

ControlP5 MainController;

SoundFile heartbeat_audio; 
SoundFile boeing_audio; 

void setup(){
   size(1700,1000); 
  
   
   
   
  
   boeing_data = loadStrings("boeing_10yrdata.csv"); 

  
   MainController = new ControlP5(this); 
  
   MainController.addButton("audio_toggle")
  .setPosition(1350,80)
  .setSize(200,40) 
  .setSwitch(true)
  .setColorActive(color(255,0,0)); 
     
    
  MainController.addSlider("gain_set")
    .setRange(1,100)
    .setSize(300,30)
    .setPosition(1350,40)
    .setValue(gain_set); 
    
  MainController.addSlider("resistor_set")
    .setRange(0.2,3)
    .setSize(50,300)
    .setPosition(1500,550)
    .setColorForeground(color(0,250,0))
    .setColorBackground(color(0,100,0))
    .setColorActive(color(0,255,0)); 
 

    heartbeat_data = loadStrings("sampled_heartbeat.csv"); 
    heartbeat_audio = new SoundFile(this,"[02]sampled_heartbeat_200.wav");     
    heartbeat_audio.rate(0.2); 
    
    boeing_audio = new SoundFile(this,"boeing_sonification.wav"); 
    boeing_audio.rate(0.75); 

 
}

public void controlEvent(ControlEvent theEvent) {
   
  if(theEvent.getController().getName().equals("audio_toggle")){
    
    play_audio = !play_audio; 
     if(play_audio){
      boeing_audio.amp(gain_set/100.0);
      heartbeat_audio.amp(0.3*(100.0 - gain_set)/100.0); 
      heartbeat_audio.loop(); 
     
      boeing_audio.loop(); 
      
    }
    else {
       boeing_audio.stop();  
       heartbeat_audio.stop(); 
    }
  }
  
  
   
  if(theEvent.getController().getName().equals("gain_set")){
    gain_set = int(theEvent.getController().getValue()); 
   
    if(play_audio){
       
      boeing_audio.amp(gain_set/100.0); 
      heartbeat_audio.amp(0.3*(100.0-gain_set)/100.0); 
      System.out.println((100.0-gain_set)/100.0); 
    }
  }
  
  if(theEvent.getController().getName().equals("resistor_set")){
    R = theEvent.getController().getValue(); 
  }
  
}

void keyPressed() {
  if(key==' ')
    drawSpike(); 
}

void drawSpike(){
  impulses.add(new Rectangle(800,800)); 
  cap_charging = 100; 
}

class Rectangle {
  float xpos,ypos,c; 
  Rectangle(float x, float y) {
    xpos = x; 
    ypos = y;
    
  }
  void update() {
    if(c >=255) c=0; else c++;
    colorMode(HSB); 
    stroke(color(c,255,255)); 
    xpos -=1;
    rect(xpos,ypos,2,50);   
    colorMode(RGB); 
  }
}
class Point {
  float xpos,ypos; 
  Point(float x, float y) {
    xpos = x; 
    ypos = y;
    
  }
  void update() {
   
    stroke(color(0,0,0)); 
    xpos -=1;
    point(xpos,ypos);    
  }
}



//adds one impulse worth of charge to cap 


float calculate_capacitor_charge(){
  if(cap_charging > 0){
    float effective_t = R * C * -1.0 * log(1.0 - (cap_charge/1.0));  
    cap_charge = 1 - exp(-1 * (effective_t + 0.01)/(R*C));
    cap_charging --;
  }
  else if (cap_charge >= 0.01)  {
    float effective_t = -1.0 * R * C * log(cap_charge/1.0); 
    cap_charge = exp(-1*(effective_t+0.01)/(R*C)); 
  }
  else{
    cap_charge = 0; 
    return cap_charge; 
  }
  
  System.out.println(cap_charge); 
  return cap_charge; 
  
  
  
}
void draw(){
  
   background(255); 
   fill(0); 
   strokeWeight(4);
   
   textSize(32); 
   text("Lost In the Noise: Plotting Emotion",125,75); 
   line(125,80,665,80); 
   stroke(color(0,0,0)); 
   
   textSize(16); 
  
   text("Heartbeat vs. Boeing Stock",width-300,30); 
   
   text("Audio Toggle",width-140,105); 
   
   text("Resistor (Tunable via. Meditation)",width-305,height-110); 
   
   text("\"Impulses\"",width/2,height-140); 
   text("Emotional Capacitor Charge/Discharge",width/2,height-250); 
   
   
   float new_voltage = calculate_capacitor_charge(); 
   
   if(new_voltage > 0){
     MainController.getController("gain_set").setValue(100 * new_voltage); 
   }
   cap_plot_points.add(new Point(800,750-100*new_voltage)); 

    
   t=0; 
   
   for(int x = 0; x < boeing_data.length; x+=2){
      boeing_signal = (gain_set/100.0) * float(boeing_data[x]); 
      heartbeat_signal = 25.0 * float(heartbeat_data[x]); 
      point(float(t) + plot_buffer_height,(height - plot_buffer_width - boeing_signal - heartbeat_signal)); 
      t++;
    };
   
 
 
   for(int i = 0; i < impulses.size(); i++){
     Rectangle rect = (Rectangle)impulses.get(i);
     if (rect.ypos < 0){
       impulses.remove(i); 
     }
     else
     rect.update(); 
     
   }
   for(int i = 0; i < cap_plot_points.size(); i++){
     Point pnt = (Point)cap_plot_points.get(i); 
     if(pnt.ypos < 0){
       cap_plot_points.remove(i); 
     }
     else
     pnt.update(); 
   }
 
    
 

}