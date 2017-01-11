import java.io.*;
import java.net.*;

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
color c = 0;
color c_b = color(0,0,0);

int mode = 0;	//0-Wheele, 1-RGB, 2-Lvl

Socket Client;
PrintStream output;

static String server = "192.168.1.15";

long tap_timer = 0;
int lvl = 0;

//Config Options
int sMode = 0; //Strip Mode

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
	String msg = ("[" + ((int) map(lvl,0,100,0,255)) + ";" + (int) map(red,0,100,0,255) +";"+ 
						(int) map(green,0,100,0,255) +";"+ (int) map(blue,0,100,0,255) +";]\r\n");
	if(Client.isConnected()) output.print(msg);
}

void setup(){

	//size(1080, 1000);
	fullScreen();
	textSize(38);
	colorMode(HSB, 2*PI, 100, 100);
	smooth();
	rgb_wheel();
	connect();
}

void draw(){
	
	if(mode > 0){	//Modo RGB - LVL

		background(0);
		noStroke();
		if(mode == 1){	//Modo RGB

			fill(255,0,0);
			rect(width/4-100, height*0.2 , 200, map(red,0,100,0,height *0.6));
			fill(0,255,0);
			rect(width/4*2-100, height*0.2 , 200, map(green,0,100,0,height *0.6));
			fill(0,0,255);
			rect(width/4*3-100, height*0.2 , 200, map(blue,0,100,0,height *0.6));

			if(mousePressed){
				if(mouseY > 60 + width/8  && mouseY < height*0.85){
					if(mouseX > width/4-150 && mouseX< width/4+150)
						red = (int) map(mouseY-height*0.2,0,height *0.6 ,0,100);
					if(red<0) red = 0; if(red>100) red = 100;

					if(mouseX > width/4*2-150 && mouseX< width/4*2+150)
						green = (int) map(mouseY-height*0.2,0,height *0.6 ,0,100);
					if(green<0) green = 0; if(green>100) green = 100;

					if(mouseX > width/4*3-150 && mouseX< width/4*3+150)
						blue = (int) map(mouseY-height*0.2,0,height *0.6,0,100);
					if(blue<0) blue = 0; if(blue>100) blue = 100;

					c = color(red,green,blue);
					send();
				}
			}
		}else{		//Modo LVL
			
			fill(255,255,255);
			rect(width/2-200, height*0.8 - map(lvl,0,100,0,height*0.6), 400, map(lvl,0,100,0,height *0.6));	
		
			if(mousePressed){
				if(mouseY > 60 + width/8 && mouseY < height*0.85){
					if(mouseX > width/2-400 && mouseX< width/2+400)
						lvl = (int) map(height*0.8 - mouseY ,0,height *0.6 ,0,100);
					if(lvl<0) lvl = 0; if(lvl>100) lvl = 100;

					if(sMode == 0) send(); else{
						//if(Client.isConnected()) output.print("[-1;0;" + sMode + ";" + lvl + ";]");
					}
				}
			}
			fill(100,100,100);
			if(sMode == 0) text("Level: " + lvl, 20, height/2); else text("Timer: " + lvl, 20, height/2);
		}
	}else{			//Modo Wheel
		if(mousePressed){
			c = get(mouseX, mouseY);
			if (c != c_b && mouseY > 60 + width/8){
				green = int(green(c));
				blue = int(blue(c)); 
				red = int(red(c) * 16);

				send();
			}
			
		}
	}


	//Modo color
	fill(c);
	if (mode == 0) stroke(0,0,100); else stroke(255,255,255);
	rect(20, 20, width/8, width/8);

	//Tower
	fill(0,0,0);
	rect(20 + width/6 , 20, width/8, width/8);

	//Mode Arduino
	rect(20 + width/6*2 , 20, width/8, width/8);
	rect(20 + width/6*3 , 20, width/8, width/8);

	//Conexion
	if (mode == 0){
		if(Client.isConnected()) fill(PI/1.8,100,80); else fill(0,100,80);
	}else{
		if(Client.isConnected()) fill(0,100,0); else fill(100,0,0);
	}
	if (mode == 0) stroke(0,0,100); else stroke(255,255,255);
	rect(width - width/8 - 20, 20, width/8, width/8);

	//Negro
	if (mode == 0) stroke(0,0,100); else stroke(255,255,255);
	fill(0,0,0);
	rect(20, height - 20 - width/8, width/8, width/8);

	//Blanco
	stroke(0,0,0);
	if (mode == 0) fill(0,0,100); else fill(255,255,255);
	rect(width - width/8 - 20, height - 20 - width/8, width/8, width/8);

	//Rectangulo texto
	noStroke();
	fill(0);
	rect(width/2-200, height - 150, 400, 80);

	//Text
	if (mode == 0) fill(0,0,100); else fill(255,255,255);
	text("Form", width/8*0.30, width/8*1.5);
	text("Tower", width/6+30, width/8*1.5);
	text("Mode", width/6*2+40, width/8*1.5);

	textSize(84);
	text(sMode, width/6*3+66, width/8*0.82);
	textSize(38);

	text("Wifi", width*0.89, width/8*1.5);

	String RGBString = str(red) + " : " + str(green) + " : " + str(blue);
	text(RGBString, width/2-RGBString.length()*9,  height - 80);

	fill(c);
	text("UnrealLed Controll", width/2-158, height-325);

	if(mousePressed && tap_timer < millis()){

		tap_timer = millis() + 500;

		if(mouseY > 20 && mouseY < 20+width/8){

			//Mode Color
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

			//Tower
			if (mouseX > 20+width/6 && mouseX < 20+width/6+width/8){
				if(mode==2) mode=1; else mode=2;
				colorMode(RGB,100,100,100);
			}

			//Mode Arduino
			if (mouseX > 20+width/6*2 && mouseX < 20+width/6*2+width/8){
				if(Client.isConnected()) output.print("[-1;0;" + sMode + ";" + lvl + " ;]");
			}

			if (mouseX > 20+width/6*3 && mouseX < 20+width/6*3+width/8){
				if(++sMode == 5) sMode = 0;
			}
			
			//Wifi
			if (mouseX > width - width/8 - 20 && mouseX < width - 20){
				connect();
			}
		}

		if( mouseY > height - 20 - width/8 && mouseY < height - 20){
			if (mouseX > 20 && mouseX < width/8 + 20){
				red=0;green=0;blue=0;
				c=color(0,0,0);
				send();
			}

			if (mouseX > width - width/8 - 20 && mouseX < width - 20){
				red=100;green=100;blue=100;
				if(mode==0){
					c=color(0,0,100);
				}else{
					c=color(100,100,100);
				} 
				send();
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