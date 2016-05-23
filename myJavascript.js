"use strict";

var numColors = 0;
var objDomMid = {};

function initMiddle() {
    var objDomNum = document.getElementById("numColors");
    objDomMid = document.getElementById("middle");
    updateMiddle(objDomNum);
}

function updateMiddle(self) {
    var num = validateNum(self, 1);

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
    newNum.setAttribute("onchange", "validateNum(this, 0)");
    newNum.setAttribute("value", 0);

    newClr.setAttribute("type", "color");
    newClr.setAttribute("name", "colorCode" + num);
    newClr.setAttribute("value", "#000000");

    newDiv.setAttribute("id", "div" + num);

    // Append elements
    newDiv.appendChild(document.createTextNode("Color #" + num));
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

function validateNum(self, min) {
    if (self.value < min) {
        self.value = min;
    }

    return self.value;
}