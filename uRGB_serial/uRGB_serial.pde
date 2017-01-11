import java.io.*;
import java.net.*;

import processing.serial.*;

float startFill;
float startAngle;
int step;
float stepLength;

float centerX;
float centerY;

float pSize;
float pAngle;
float pFill;
float bValue;

int red = 0,green = 0,blue = 0;
int bred = 0, bgreen = 0, bblue = 0;

color c = 0;
color c_b = color(0,0,0);

int mode = 0;	//0-Wheele, 1-RGB, 2-Lvl
int strip = 0;  //0-Sup, 1-Sup

Socket Client;
PrintStream output;

Serial s_port;

static String server = "192.168.1.132";

long tap_timer = 0;
int lvl = 0;

void connect(){
	try{
		Client = new Socket();
		Client.connect(new InetSocketAddress(server, 80), 1000);
		output = new PrintStream(Client.getOutputStream());
	}
	catch (UnknownHostException e) {
	  println(e);
	}catch (IOException e) {
	  println(e);
	}
}

void send(){
	if(s_port.available() > 0){
		if(s_port.read() == 'B'){
			char lvl_output = (char) map(lvl,0,100,0,127);
			s_port.write(lvl_output);

			if(strip == 0){
				s_port.write((char) (red));
				s_port.write((char) (green));
				s_port.write((char) (blue));
				//s_port.write((char) (bred));
				//s_port.write((char) (bgreen));
				//s_port.write((char) (bblue));
			}else{
				s_port.write((char) (bred));
				s_port.write((char) (bgreen));
				s_port.write((char) (bblue));
				//s_port.write((char) (red));
				//s_port.write((char) (green));
				//s_port.write((char) (blue));	
			}
		}
	}
}

void setup(){

	size(600, 800);
	//fullScreen();
	textSize(36);
	colorMode(HSB, 2*PI, 100, 100);
	smooth();
	rgb_wheel();
	s_port = new Serial(this,Serial.list()[0],115200);
	//connect();
}

void draw(){
	
	if(mode > 0){

		background(0);

		if(mode == 1){
			noStroke();
			fill(255,0,0);
			rect(width/4-25, height*0.2 , 50, map(red,0,100,0,height *0.6));
			fill(0,255,0);
			rect(width/4*2-25, height*0.2 , 50, map(green,0,100,0,height *0.6));
			fill(0,0,255);
			rect(width/4*3-25, height*0.2 , 50, map(blue,0,100,0,height *0.6));

			if(mousePressed){
				if(mouseY > height*0.15 && mouseY < height*0.85){
					if(mouseX > width/4-50 && mouseX< width/4+50)
						red = (int) map(mouseY-height*0.2,0,height *0.6 ,0,100);
					if(red<0) red = 0; if(red>100) red = 100;

					if(mouseX > width/4*2-50 && mouseX< width/4*2+50)
						green = (int) map(mouseY-height*0.2,0,height *0.6 ,0,100);
					if(green<0) green = 0; if(green>100) green = 100;

					if(mouseX > width/4*3-50 && mouseX< width/4*3+50)
						blue = (int) map(mouseY-height*0.2,0,height *0.6,0,100);
					if(blue<0) blue = 0; if(blue>100) blue = 100;
				}

				c = color(red,green,blue);
				send();
			}
		}else{
			noStroke();
			fill(255,255,255);
			rect(width/2-200, height*0.8 - map(lvl,0,100,0,height*0.6), 400, map(lvl,0,100,0,height *0.6));	
		
			if(mousePressed){
				if(mouseY > height*0.15 && mouseY < height*0.85){
					if(mouseX > width/2-400 && mouseX< width/2+400)
						lvl = (int) map(height*0.8 - mouseY ,0,height *0.6 ,0,100);
					if(lvl<0) lvl = 0; if(lvl>100) lvl = 100;
				}
				send();
			}

			fill(100,100,100);
			text("Level: " + lvl, 20, height/2);
		}

		fill(c);
		stroke(255,255,255);
		rect(20, 20, width/8, width/8);

		stroke(255,255,255);
		if(strip == 0) fill(0,75,0); else fill(75,0,0);
		rect(width - width/8 - 20, 20, width/8, width/8);

		stroke(255,255,255);
		fill(0,0,0);
		rect(20, height - 20 - width/8, width/8, width/8);

		stroke(0,0,0);
		fill(255,255,255);
		rect(width - width/8 - 20, height - 20 - width/8, width/8, width/8);

		noStroke();

		fill(100,100,100);
		String RGBString = str(red) + " : " + str(green) + " : " + str(blue);
		text(RGBString, width/2-90, 73);
		fill(c);
		text("UnrealLed Controll", width/2-155, height - 40);

	}else{
		if(mousePressed){
			c = get(mouseX, mouseY);
			if (c != c_b){
				green = int(green(c));
				blue = int(blue(c)); 
				red = int(red(c) * 16); 
			}

			send();
		}

		fill(c);
		stroke(0,0,100);
		rect(20, 20, width/8, width/8);

		if(strip == 0) fill(PI/1.8,100,80); else fill(0,100,80);
		stroke(0,0,100);
		rect(width - width/8 - 20, 20, width/8, width/8);

		stroke(0,0,100);
		fill(0,0,0);
		rect(20, height - 20 - width/8, width/8, width/8);

		stroke(0,0,0);
		fill(0,0,100);
		rect(width - width/8 - 20, height - 20 - width/8, width/8, width/8);

		noStroke();
		fill(0);
		rect(width/2-150, 30, 300, 50);

		fill(0,0,100);
		String RGBString = str(red) + " : " + str(green) + " : " + str(blue);
		text(RGBString, width/2-90, 73);
		fill(c);
		text("UnrealLed Controll", width/2-155, height-40);
	}

	if(mousePressed && tap_timer < millis()){

		tap_timer = millis() + 250;

		if (mouseX > width/4 && mouseX < width - width/4 &&  mouseY > height - 100){
				if(mode==2) mode=1; else mode=2;
				colorMode(RGB,100,100,100);
		}

		if( mouseY > height - 20 - width/8 && mouseY < height - 20){
			if (mouseX > 20 && mouseX < width/8 + 20){
				red=0;green=0;blue=0;
					c=color(0,0,0);
			}

			if (mouseX > width - width/8 - 20 && mouseX < width - 20){
				red=100;green=100;blue=100;
				if(mode==0){
					c=color(0,0,100);
				}else{
					c=color(100,100,100);
				} 	
			}
		}

		if(mouseY > 20 && mouseY < 20+width/8){
			if(mouseX > 20 && mouseX< 20+width/8){
					if(mode==1){
						colorMode(HSB, 2*PI, 100, 100);
						rgb_wheel();
						mode = 0;
					}else{
						colorMode(RGB,100,100,100);
						background(0);
						mode=1;
					} 
			}

			if (mouseX > width - width/8 - 20 && mouseX < width - 20){
				int tred = red, tgreen = green, tblue = blue;
				red = bred; green = green; blue = bgreen;
				bred = tred; bgreen = tgreen; bblue = tblue;

				if(strip == 0) strip = 1; else strip = 0;
			}
		}
	}

	
}

void rgb_wheel(){
	background(0,0,0);
	smooth();
	ellipseMode(CENTER);
	noStroke();
	
	step = 40;
	centerX = width/2;
	centerY = height/2;
	startFill = PI + PI/3;
	startAngle = PI;
	stepLength = PI/step;
	
	pAngle = startAngle + 3*stepLength;
	pFill = startFill + 3*stepLength;
	bValue = 100;
	
	// draw arcs
	for(int i=0; i< 2* step; i++){
		fill(startFill, 85, 100);
		startFill = startFill + stepLength;
		startAngle = startAngle + stepLength;
		
		if (startFill > 2* PI){
			startFill = startFill - 2 * PI;
		}

		pFill = startFill + 3*stepLength;
		pAngle = startAngle + 3*stepLength;
		pSize = width-width*0.2;
		bValue = 100;

		if (pFill > 2* PI) pFill = pFill - 2 * PI;
		fill(pFill, bValue, bValue);

		arc(centerX, centerY, pSize+((width-width*0.2)/step)*10, pSize+((width-width*0.2)/step)*10, pAngle, pAngle+stepLength);

		for(int j=0; j<step; j++){
			if (pFill > 2* PI) pFill = pFill - 2 * PI;
			fill(pFill, bValue, bValue);
			arc(centerX, centerY, pSize, pSize, pAngle, pAngle+stepLength);
			bValue = bValue - 100/step;
			pSize = pSize - (width-width*0.2)/step;
		}
	}

	fill(0,0,0);
	ellipse(centerX, centerY, 10, 10);
}