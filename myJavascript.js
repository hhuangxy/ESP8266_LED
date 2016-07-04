"use strict";

var numColors = 0;
var objDomMid = {};

function init() {
  // Make all-block active
  document.getElementById("all").style.display = "block";

  // Initialize advance-block
  var objDomNum = document.getElementById("numColors");
  objDomMid = document.getElementById("middle");
  updateMiddle(objDomNum);
}

function updateMiddle(self) {
  var num = validateNum(self, 1, 27);

  while (num > numColors) {
    numColors++;
    addDiv(objDomMid, numColors);
  }

  while (num < numColors) {
    numColors--;
    remDiv(objDomMid);
  }
}

function addDiv(objDom, num) {
  var newDiv = document.createElement("div");
  var newBrk = document.createElement("br");
  var newNum = document.createElement("input");
  var newClr = document.createElement("input");

  // Set attributes
  newNum.setAttribute("type", "number");
  newNum.setAttribute("name", "numLED" + num);
  newNum.setAttribute("onchange", "validateNum(this, 0, 27)");
  newNum.setAttribute("value", 0);

  newClr.setAttribute("type", "color");
  newClr.setAttribute("name", "colorCode" + num);
  newClr.setAttribute("value", "#000000");

  newDiv.setAttribute("id", "div" + num);

  // Append elements
  newDiv.appendChild(document.createTextNode("Colour #" + num));
  newDiv.appendChild(newBrk);
  newDiv.appendChild(document.createTextNode("Number of LEDs"));
  newDiv.appendChild(newNum);
  newDiv.appendChild(newClr);

  objDom.appendChild(newDiv);
}

function remDiv(objDom) {
  var lastChild = objDom.lastChild;
  objDom.removeChild(lastChild)
}

function validateNum(self, min, max) {
  if (self.value < min) {
    self.value = min;
  }

  if (self.value > max) {
    self.value = max;
  }

  return self.value;
}

function openCity(evt, cityName) {
  // Declare all variables
  var i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the link that opened the tab
  document.getElementById(cityName).style.display = "block";
  evt.currentTarget.className += " active";
}
