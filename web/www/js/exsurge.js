(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define("exsurge", [], factory);
	else if(typeof exports === 'object')
		exports["exsurge"] = factory();
	else
		root["exsurge"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	//
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _Exsurge = __webpack_require__(1);
	
	Object.keys(_Exsurge).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge[key];
	    }
	  });
	});
	
	var _Exsurge2 = __webpack_require__(2);
	
	Object.keys(_Exsurge2).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge2[key];
	    }
	  });
	});
	
	var _Exsurge3 = __webpack_require__(3);
	
	Object.keys(_Exsurge3).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge3[key];
	    }
	  });
	});
	
	var _Exsurge4 = __webpack_require__(4);
	
	Object.keys(_Exsurge4).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge4[key];
	    }
	  });
	});
	
	var _Exsurge5 = __webpack_require__(6);
	
	Object.keys(_Exsurge5).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge5[key];
	    }
	  });
	});
	
	var _ExsurgeChant = __webpack_require__(9);
	
	Object.keys(_ExsurgeChant).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _ExsurgeChant[key];
	    }
	  });
	});
	
	var _ExsurgeChant2 = __webpack_require__(8);
	
	Object.keys(_ExsurgeChant2).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _ExsurgeChant2[key];
	    }
	  });
	});
	
	var _ExsurgeChant3 = __webpack_require__(11);
	
	Object.keys(_ExsurgeChant3).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _ExsurgeChant3[key];
	    }
	  });
	});
	
	var _Exsurge6 = __webpack_require__(10);
	
	Object.keys(_Exsurge6).forEach(function (key) {
	  if (key === "default") return;
	  Object.defineProperty(exports, key, {
	    enumerable: true,
	    get: function get() {
	      return _Exsurge6[key];
	    }
	  });
	});
	
	
	// client side support
	
	if (typeof document !== 'undefined') {
	  var ChantVisualElementPrototype = Object.create(HTMLElement.prototype);
	
	  ChantVisualElementPrototype.createdCallback = function () {
	    var ctxt = new _Exsurge4.ChantContext();
	
	    ctxt.lyricTextFont = "'Crimson Text', serif";
	    ctxt.lyricTextSize *= 1.2;
	    ctxt.dropCapTextFont = ctxt.lyricTextFont;
	    ctxt.annotationTextFont = ctxt.lyricTextFont;
	
	    var useDropCap = true;
	    var useDropCapAttr = this.getAttribute("use-drop-cap");
	    if (useDropCapAttr === 'false') useDropCap = false;
	
	    var score = _Exsurge6.Gabc.loadChantScore(ctxt, this.innerText, useDropCap);
	
	    var annotationAttr = this.getAttribute("annotation");
	    if (annotationAttr) {
	      // add an annotation
	      score.annotation = new _Exsurge4.Annotation(ctxt, annotationAttr);
	    }
	
	    var _element = this;
	
	    var width = 0;
	    var doLayout = function doLayout() {
	      var newWidth = _element.parentElement.clientWidth;
	      if (width === newWidth) return;
	      width = newWidth;
	      // perform layout on the chant
	      score.performLayout(ctxt, function () {
	        score.layoutChantLines(ctxt, width, function () {
	          // render the score to svg code
	          _element.innerHTML = score.createSvgFragment(ctxt);
	        });
	      });
	    };
	    doLayout();
	    if (window.addEventListener) window.addEventListener('resize', doLayout, false);else if (window.attachEvent) window.attachEvent('onresize', doLayout);
	  };
	
	  ChantVisualElementPrototype.attachedCallback = function () {};
	
	  document.registerElement = document.registerElement || function () {};
	  // register the custom element
	  var ChantVisualElement = document.registerElement('chant-visual', {
	    prototype: ChantVisualElementPrototype
	  });
	}

/***/ },
/* 1 */
/***/ function(module, exports) {

	"use strict";
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	exports.DeviceIndependent = DeviceIndependent;
	exports.Centimeters = Centimeters;
	exports.Millimeters = Millimeters;
	exports.Inches = Inches;
	exports.ToCentimeters = ToCentimeters;
	exports.ToMillimeters = ToMillimeters;
	exports.ToInches = ToInches;
	exports.generateRandomGuid = generateRandomGuid;
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	//
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var Units = exports.Units = {
	  // enums
	  DeviceIndepenedent: 0, // device independent units: 96/inch
	  Centimeters: 1,
	  Millimeters: 2,
	  Inches: 3,
	
	  // constants for device independent units (diu)
	  DIU_PER_INCH: 96,
	  DIU_PER_CENTIMETER: 96 / 2.54,
	
	  ToDeviceIndependent: function ToDeviceIndependent(n, inputUnits) {
	    switch (inputUnits) {
	      case Centimeters:
	        return n * DIU_PER_CENTIMETER;
	      case Millimeters:
	        return n * DIU_PER_CENTIMETER / 10;
	      case Inches:
	        return n * DIU_PER_INCH;
	      default:
	        return n;
	    }
	  },
	
	  FromDeviceIndependent: function FromDeviceIndependent(n, outputUnits) {
	    switch (outputUnits) {
	      case Centimeters:
	        return n / DIU_PER_CENTIMETER;
	      case Millimeters:
	        return n / DIU_PER_CENTIMETER * 10;
	      case Inches:
	        return n / DIU_PER_INCH;
	      default:
	        return n;
	    }
	  },
	
	  StringToUnitsType: function StringToUnitsType(s) {
	    switch (s.ToLower()) {
	      case "in":
	      case "inches":
	        return Inches;
	
	      case "cm":
	      case "centimeters":
	        return Centimeters;
	
	      case "mm":
	      case "millimeters":
	        return Millimeters;
	
	      case "di":
	      case "device-independent":
	        return DeviceIndepenedent;
	
	      default:
	        return DeviceIndepenedent;
	    }
	  },
	
	  UnitsTypeToString: function UnitsTypeToString(units) {
	    switch (units) {
	      case Inches:
	        return "in";
	      case Centimeters:
	        return "cm";
	      case Millimeters:
	        return "mm";
	      case DeviceIndepenedent:
	        return "device-independent";
	      default:
	        return "device-independent";
	    }
	  }
	};
	
	function DeviceIndependent(n) {
	  return n;
	}
	
	function Centimeters(n) {
	  return Units.ToDeviceIndependent(n, Units.Centimeters);
	}
	
	function Millimeters(n) {
	  return Units.ToDeviceIndependent(n, Units.Millimeters);
	}
	
	function Inches(n) {
	  return Units.ToDeviceIndependent(n, Units.Inches);
	}
	
	function ToCentimeters(n) {
	  return Units.FromDeviceIndependent(n, Units.Centimeters);
	}
	
	function ToMillimeters(n) {
	  return Units.FromDeviceIndependent(n, Units.Millimeters);
	}
	
	function ToInches(n) {
	  return Units.FromDeviceIndependent(n, Units.Inches);
	}
	
	/*
	 * Point
	 */
	
	var Point = exports.Point = function () {
	  function Point(x, y) {
	    _classCallCheck(this, Point);
	
	    this.x = typeof x !== 'undefined' ? x : 0;
	    this.y = typeof y !== 'undefined' ? y : 0;
	  }
	
	  _createClass(Point, [{
	    key: "clone",
	    value: function clone() {
	      return new Point(this.x, this.y);
	    }
	  }, {
	    key: "equals",
	    value: function equals(point) {
	      return this.x === point.x && this.y === point.y;
	    }
	  }]);
	
	  return Point;
	}();
	
	/*
	 * Rect
	 */
	
	
	var Rect = exports.Rect = function () {
	  function Rect(x, y, width, height) {
	    _classCallCheck(this, Rect);
	
	    this.x = typeof x !== 'undefined' ? x : Infinity;
	    this.y = typeof y !== 'undefined' ? y : Infinity;
	    this.width = typeof width !== 'undefined' ? width : -Infinity;
	    this.height = typeof height !== 'undefined' ? height : -Infinity;
	  }
	
	  _createClass(Rect, [{
	    key: "clone",
	    value: function clone() {
	      return new Rect(this.x, this.y, this.width, this.height);
	    }
	  }, {
	    key: "isEmpty",
	    value: function isEmpty() {
	      return this.x === Infinity && this.y === Infinity && this.width === -Infinity && this.height === -Infinity;
	    }
	
	    // convenience method
	
	  }, {
	    key: "right",
	    value: function right() {
	      return this.x + this.width;
	    }
	  }, {
	    key: "bottom",
	    value: function bottom() {
	      return this.y + this.height;
	    }
	  }, {
	    key: "equals",
	    value: function equals(rect) {
	      return this.x === rect.x && this.y === rect.y && this.width === rect.width && this.height === rect.height;
	    }
	
	    // other can be a Point or a Rect
	
	  }, {
	    key: "contains",
	    value: function contains(other) {
	      if (other instanceof Point) {
	        return other.x >= this.x && other.x <= this.x + this.width && other.y >= this.y && other.y <= this.y + this.height;
	      } else {
	        // better be instance of Rect
	        return this.x <= other.x && this.x + this.width >= other.x + other.width && this.y <= other.y && this.y + this.height >= other.y + other.height;
	      }
	    }
	  }, {
	    key: "union",
	    value: function union(rect) {
	
	      var right = Math.max(this.x + this.width, rect.x + rect.width);
	      var bottom = Math.max(this.y + this.height, rect.y + rect.height);
	
	      this.x = Math.min(this.x, rect.x);
	      this.y = Math.min(this.y, rect.y);
	
	      this.width = right - this.x;
	      this.height = bottom - this.y;
	    }
	  }]);
	
	  return Rect;
	}();
	
	/**
	 * Margins
	 *
	 * @class
	 */
	
	
	var Margins = exports.Margins = function () {
	  function Margins(left, top, right, bottom) {
	    _classCallCheck(this, Margins);
	
	    this.left = typeof left !== 'undefined' ? left : 0;
	    this.top = typeof top !== 'undefined' ? top : 0;
	    this.right = typeof right !== 'undefined' ? right : 0;
	    this.bottom = typeof bottom !== 'undefined' ? bottom : 0;
	  }
	
	  _createClass(Margins, [{
	    key: "clone",
	    value: function clone() {
	      return new Margins(this.left, this.top, this.right, this.bottom);
	    }
	  }, {
	    key: "equals",
	    value: function equals(margins) {
	      return this.left === margins.left && this.top === margins.top && this.right === margins.right && this.bottom === margins.bottom;
	    }
	  }]);
	
	  return Margins;
	}();
	
	/**
	 * Size
	 *
	 * @class
	 */
	
	
	var Size = exports.Size = function () {
	  function Size(width, height) {
	    _classCallCheck(this, Size);
	
	    this.width = typeof width !== 'undefined' ? width : 0;
	    this.height = typeof height !== 'undefined' ? height : 0;
	  }
	
	  _createClass(Size, [{
	    key: "clone",
	    value: function clone() {
	      return new Size(this.width, this.height);
	    }
	  }, {
	    key: "equals",
	    value: function equals(size) {
	      return this.width === size.width && this.height === size.height;
	    }
	  }]);
	
	  return Size;
	}();
	
	/*
	 * Pitches, notes
	 */
	
	
	var Step = exports.Step = {
	  Do: 0,
	  Du: 1,
	  Re: 2,
	  Me: 3,
	  Mi: 4,
	  Fa: 5,
	  Fu: 6,
	  So: 7,
	  La: 9,
	  Te: 10,
	  Ti: 11
	};
	
	// this little array helps map step values to staff positions. The numeric values of steps
	// correspond to whole step increments (2) or half step increments (1). This gives us the ability
	// to compare pitches precisely, but makes it challenging to place steps on the staff. this little
	// array maps the steps to an incremental position the steps take on the staff line. This works
	// so simply because chant only uses do and fa clefs, and only has a flatted ti (te), making
	// for relatively easy mapping to staff line locations.
	//                         Do Du Re Me Mi Fa Fu So    La Te Ti
	var __StepToStaffPosition = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6];
	var __StaffOffsetToStep = [Step.Do, Step.Re, Step.Mi, Step.Fa, Step.So, Step.La, Step.Ti]; // no accidentals in this one
	
	var Pitch = exports.Pitch = function () {
	  function Pitch(step, octave) {
	    _classCallCheck(this, Pitch);
	
	    this.step = step;
	    this.octave = octave;
	  }
	
	  _createClass(Pitch, [{
	    key: "toInt",
	    value: function toInt() {
	      return this.octave * 12 + this.step;
	    }
	  }, {
	    key: "isHigherThan",
	    value: function isHigherThan(pitch) {
	      return this.toInt() > pitch.toInt();
	    }
	  }, {
	    key: "isLowerThan",
	    value: function isLowerThan(pitch) {
	      return this.toInt() < pitch.toInt();
	    }
	  }, {
	    key: "equals",
	    value: function equals(pitch) {
	      return this.toInt() === pitch.toInt();
	    }
	  }], [{
	    key: "stepToStaffOffset",
	    value: function stepToStaffOffset(step) {
	      return __StepToStaffPosition[step];
	    }
	  }, {
	    key: "staffOffsetToStep",
	    value: function staffOffsetToStep(offset) {
	      while (offset < 0) {
	        offset = __StaffOffsetToStep.length + offset;
	      }return __StaffOffsetToStep[offset % __StaffOffsetToStep.length];
	    }
	  }]);
	
	  return Pitch;
	}();
	
	function generateRandomGuid() {
	  function s4() {
	    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
	  }
	  return s4() + s4();
	}

/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.Spanish = exports.Latin = exports.Language = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	/**
	 * @class
	 */
	
	var Language = exports.Language = function () {
	  function Language(name) {
	    _classCallCheck(this, Language);
	
	    this.name = typeof name !== 'undefined' ? name : "<unknown>";
	  }
	
	  /**
	   * @param {String} text The string to parsed into words.
	   * @return {Word[]} the resulting parsed words from syllabification
	   */
	
	
	  _createClass(Language, [{
	    key: 'syllabify',
	    value: function syllabify(text) {
	
	      var parsedWords = [];
	
	      if (typeof text === 'undefined' || text === "") return parsedWords;
	
	      // Divide the text into words separated by whitespace
	      var words = text.split(/[\s]+/);
	
	      for (var i = 0, end = words.length; i < end; i++) {
	        parsedWords.push(this.syllabifyWord(words[i]));
	      }return parsedWords;
	    }
	  }]);
	
	  return Language;
	}();
	
	/**
	 * @class
	 */
	
	
	var Latin = exports.Latin = function (_Language) {
	  _inherits(Latin, _Language);
	
	  /**
	   * @constructs
	   */
	
	  function Latin() {
	    _classCallCheck(this, Latin);
	
	    // fixme: ui is only diphthong in the exceptional cases below (according to Wheelock's Latin)
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(Latin).call(this, "Latin"));
	
	    _this.diphthongs = ["ae", "au", "oe", "aé", "áu", "oé"];
	    // for centering over the vowel, we will need to know any combinations that might be diphthongs:
	    _this.possibleDiphthongs = _this.diphthongs.concat(["ei", "eu", "ui", "éi", "éu", "úi"]);
	
	    // some words that are simply exceptions to standard syllabification rules!
	    var wordExceptions = new Object();
	
	    // ui combos pronounced as diphthongs
	    wordExceptions["huius"] = ["hui", "us"];
	    wordExceptions["cuius"] = ["cui", "us"];
	    wordExceptions["huic"] = ["huic"];
	    wordExceptions["cui"] = ["cui"];
	    wordExceptions["hui"] = ["hui"];
	
	    // eu combos pronounced as diphthongs
	    wordExceptions["euge"] = ["eu", "ge"];
	    wordExceptions["seu"] = ["seu"];
	
	    _this.vowels = ['a', 'e', 'i', 'o', 'u', 'á', 'é', 'í', 'ó', 'ú', 'æ', 'œ', 'ǽ', // no accented œ in unicode?
	    'y']; // y is treated as a vowel; not native to Latin but useful for words borrowed from Greek
	
	    _this.vowelsThatMightBeConsonants = ['i', 'u'];
	
	    _this.muteConsonantsAndF = ['b', 'c', 'd', 'g', 'p', 't', 'f'];
	
	    _this.liquidConsonants = ['l', 'r'];
	    return _this;
	  }
	
	  // c must be lowercase!
	
	
	  _createClass(Latin, [{
	    key: 'isVowel',
	    value: function isVowel(c) {
	      for (var i = 0, end = this.vowels.length; i < end; i++) {
	        if (this.vowels[i] === c) return true;
	      }return false;
	    }
	  }, {
	    key: 'isVowelThatMightBeConsonant',
	    value: function isVowelThatMightBeConsonant(c) {
	      for (var i = 0, end = this.vowelsThatMightBeConsonants.length; i < end; i++) {
	        if (this.vowelsThatMightBeConsonants[i] === c) return true;
	      }return false;
	    }
	
	    // substring should be a vowel and the character following
	
	  }, {
	    key: 'isVowelActingAsConsonant',
	    value: function isVowelActingAsConsonant(substring) {
	      return this.isVowelThatMightBeConsonant(substring[0]) && this.isVowel(substring[1]);
	    }
	
	    /**
	     * f is not a mute consonant, but we lump it together for syllabification
	     * since it is syntactically treated the same way
	     *
	     * @param {String} c The character to test; must be lowercase
	     * @return {boolean} true if c is an f or a mute consonant
	     */
	
	  }, {
	    key: 'isMuteConsonantOrF',
	    value: function isMuteConsonantOrF(c) {
	      for (var i = 0, end = this.muteConsonantsAndF.length; i < end; i++) {
	        if (this.muteConsonantsAndF[i] === c) return true;
	      }return false;
	    }
	
	    /**
	     *
	     * @param {String} c The character to test; must be lowercase
	     * @return {boolean} true if c is a liquid consonant
	     */
	
	  }, {
	    key: 'isLiquidConsonant',
	    value: function isLiquidConsonant(c) {
	      for (var i = 0, end = this.liquidConsonants.length; i < end; i++) {
	        if (this.liquidConsonants[i] === c) return true;
	      }return false;
	    }
	
	    /**
	     *
	     * @param {String} s The string to test; must be lowercase
	     * @return {boolean} true if s is a diphthong
	     */
	
	  }, {
	    key: 'isDiphthong',
	    value: function isDiphthong(s) {
	      for (var i = 0, end = this.diphthongs.length; i < end; i++) {
	        if (this.diphthongs[i] === s) return true;
	      }return false;
	    }
	
	    /**
	     *
	     * @param {String} s The string to test; must be lowercase
	     * @return {boolean} true if s is a diphthong
	     */
	
	  }, {
	    key: 'isPossibleDiphthong',
	    value: function isPossibleDiphthong(s) {
	      for (var i = 0, end = this.possibleDiphthongs.length; i < end; i++) {
	        if (this.possibleDiphthongs[i] === s) return true;
	      }return false;
	    }
	
	    /**
	     * Rules for Latin syllabification (from Collins, "A Primer on Ecclesiastical Latin")
	     *
	     * Divisions occur when:
	     *   1. After open vowels (those not followed by a consonant) (e.g., "pi-us" and "De-us")
	     *   2. After vowels followed by a single consonant (e.g., "vi-ta" and "ho-ra")
	     *   3. After the first consonant when two or more consonants follow a vowel
	     *      (e.g., "mis-sa", "minis-ter", and "san-ctus").
	     *
	     * Exceptions:
	     *   1. In compound words the consonants stay together (e.g., "de-scribo").
	     *   2. A mute consonant (b, c, d, g, p, t) or f followed by a liquid consonant (l, r)
	     *      go with the succeeding vowel: "la-crima", "pa-tris"
	     *
	     * In addition to these rules, Wheelock's Latin provides this sound exception:
	     *   -  Also counted as single consonants are qu and the aspirates ch, ph,
	     *      th, which should never be separated in syllabification:
	     *      architectus, ar-chi-tec-tus; loquacem, lo-qua-cem.
	     *
	     */
	
	  }, {
	    key: 'syllabifyWord',
	    value: function syllabifyWord(word) {
	      var syllables = [];
	      var haveCompleteSyllable = false;
	      var previousWasVowel = false;
	      var workingString = word.toLowerCase();
	      var startSyllable = 0;
	
	      var c, lookahead, haveLookahead;
	
	      // a helper function to create syllables
	      var makeSyllable = function makeSyllable(length) {
	        if (haveCompleteSyllable) {
	          syllables.push(word.substr(startSyllable, length));
	          startSyllable += length;
	        }
	
	        haveCompleteSyllable = false;
	      };
	
	      for (var i = 0, wordLength = workingString.length; i < wordLength; i++) {
	
	        c = workingString[i];
	
	        // get our lookahead in case we need them...
	        lookahead = '*';
	        haveLookahead = i + 1 < wordLength;
	
	        if (haveLookahead) lookahead = workingString[i + 1];
	
	        var cIsVowel = this.isVowel(c);
	
	        // i is a special case for a vowel. when i is at the beginning
	        // of the word (Iesu) or i is between vowels (alleluia),
	        // then the i is treated as a consonant (y)
	        if (c === 'i') {
	          if (i === 0 && haveLookahead && this.isVowel(lookahead)) cIsVowel = false;else if (previousWasVowel && haveLookahead && this.isVowel(lookahead)) {
	            cIsVowel = false;
	          }
	        }
	
	        if (c === '-') {
	
	          // a hyphen forces a syllable break, which effectively resets
	          // the logic...
	
	          haveCompleteSyllable = true;
	          previousWasVowel = false;
	          makeSyllable(i - startSyllable);
	          startSyllable++;
	        } else if (cIsVowel) {
	
	          // once we get a vowel, we have a complete syllable
	          haveCompleteSyllable = true;
	
	          if (previousWasVowel && !this.isDiphthong(workingString[i - 1] + "" + c)) {
	            makeSyllable(i - startSyllable);
	            haveCompleteSyllable = true;
	          }
	
	          previousWasVowel = true;
	        } else if (haveLookahead) {
	
	          if (c === 'q' && lookahead === 'u' || lookahead === 'h' && (c === 'c' || c === 'p' || c === 't')) {
	            // handle wheelock's exceptions for qu, ch, ph and th
	            makeSyllable(i - startSyllable);
	            i++; // skip over the 'h' or 'u'
	          } else if (previousWasVowel && this.isVowel(lookahead)) {
	              // handle division rule 2
	              makeSyllable(i - startSyllable);
	            } else if (this.isMuteConsonantOrF(c) && this.isLiquidConsonant(lookahead)) {
	              // handle exception 2
	              makeSyllable(i - startSyllable);
	            } else if (haveCompleteSyllable) {
	              // handle division rule 3
	              makeSyllable(i + 1 - startSyllable);
	            }
	
	          previousWasVowel = false;
	        }
	      }
	
	      // if we have a complete syllable, we can add it as a new one. Otherwise
	      // we tack the remaining characters onto the last syllable.
	      if (haveCompleteSyllable) syllables.push(word.substr(startSyllable));else if (startSyllable > 0) syllables[syllables.length - 1] += word.substr(startSyllable);
	
	      return syllables;
	    }
	
	    /**
	     * @param {String} s the string to search
	     * @param {Number} startIndex The index at which to start searching for a vowel in the string
	     * @retuns a custom class with three properties: {found: (true/false) startIndex: (start index in s of vowel segment) length ()}
	     */
	
	  }, {
	    key: 'findVowelSegment',
	    value: function findVowelSegment(s, startIndex) {
	
	      var i, end, index;
	      var workingString = s.toLowerCase();
	
	      // do we have a diphthong?
	      for (i = 0, end = this.possibleDiphthongs.length; i < end; i++) {
	        var d = this.possibleDiphthongs[i];
	        index = workingString.indexOf(d, startIndex);
	
	        if (index >= 0) return { found: true, startIndex: index, length: d.length };
	      }
	
	      // no diphthongs. Let's look for single vowels then...
	      for (i = 0, end = this.vowels.length; i < end; i++) {
	        index = workingString.indexOf(this.vowels[i], startIndex);
	
	        if (index >= 0) {
	          // if the first vowel found might also be a consonant (U or I), and it is immediately followed by another vowel, (e.g., sanguis, quis), the first u counts as a consonant:
	          // (in practice, this only affects words such as equus that contain a uu, since the alphabetically earlier vowel would be found before the U)
	          if (this.isVowelActingAsConsonant(workingString.substr(index, 2))) {
	            ++index;
	          }
	          return { found: true, startIndex: index, length: 1 };
	        }
	      }
	
	      // no vowels sets found after startIndex!
	      return { found: false, startIndex: -1, length: -1 };
	    }
	  }]);
	
	  return Latin;
	}(Language);
	
	/**
	 * @class
	 */
	
	
	var Spanish = exports.Spanish = function (_Language2) {
	  _inherits(Spanish, _Language2);
	
	  function Spanish() {
	    _classCallCheck(this, Spanish);
	
	    var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(Spanish).call(this, "Spanish"));
	
	    _this2.vowels = ['a', 'e', 'i', 'o', 'u', 'y', 'á', 'é', 'í', 'ó', 'ú', 'ü'];
	
	    _this2.weakVowels = ['i', 'u', 'ü', 'y'];
	
	    _this2.strongVowels = ['a', 'e', 'o', 'á', 'é', 'í', 'ó', 'ú'];
	
	    _this2.diphthongs = ["ai", "ei", "oi", "ui", "ia", "ie", "io", "iu", "au", "eu", "ou", "ua", "ue", "uo", "ái", "éi", "ói", "úi", "iá", "ié", "ió", "iú", "áu", "éu", "óu", "uá", "ué", "uó", "üe", "üi"];
	
	    _this2.uDiphthongExceptions = ["gue", "gui", "qua", "que", "qui", "quo"];
	    return _this2;
	  }
	
	  // c must be lowercase!
	
	
	  _createClass(Spanish, [{
	    key: 'isVowel',
	    value: function isVowel(c) {
	      for (var i = 0, end = this.vowels.length; i < end; i++) {
	        if (this.vowels[i] === c) return true;
	      }return false;
	    }
	
	    /**
	     * @param {String} c The character to test; must be lowercase
	     * @return {boolean} true if c is an f or a mute consonant
	     */
	
	  }, {
	    key: 'isWeakVowel',
	    value: function isWeakVowel(c) {
	      for (var i = 0, end = this.weakVowels.length; i < end; i++) {
	        if (this.weakVowels[i] === c) return true;
	      }return false;
	    }
	
	    /**
	     * @param {String} c The character to test; must be lowercase
	     * @return {boolean} true if c is an f or a mute consonant
	     */
	
	  }, {
	    key: 'isStrongVowel',
	    value: function isStrongVowel(c) {
	      for (var i = 0, end = this.strongVowels.length; i < end; i++) {
	        if (this.strongVowels[i] === c) return true;
	      }return false;
	    }
	
	    /**
	     *
	     * @param {String} s The string to test; must be lowercase
	     * @return {boolean} true if s is a diphthong
	     */
	
	  }, {
	    key: 'isDiphthong',
	    value: function isDiphthong(s) {
	      for (var i = 0, end = this.diphthongs.length; i < end; i++) {
	        if (this.diphthongs[i] === s) return true;
	      }return false;
	    }
	  }, {
	    key: 'createSyllable',
	    value: function createSyllable(text) {
	
	      /*
	          var accented = false;
	          var ellidesToNext = false;
	      
	          if (text.length > 0) {
	              
	              if (text[0] == '`') {
	                  accented = true;
	                  text = text.substr(1);
	              }
	      
	              if (text[text.length - 1] == '_') {
	                  ellidesToNext = true;
	                  text = text.substr(0, text.length - 1);
	              }
	          }
	      
	          var s = new Syllable(text);
	      
	          s.isMusicalAccent = accented;
	          s.elidesToNext = ellidesToNext;*/
	
	      return text;
	    }
	
	    /**
	     */
	
	  }, {
	    key: 'syllabifyWord',
	    value: function syllabifyWord(word) {
	
	      var syllables = [];
	
	      var haveCompleteSyllable = false;
	      var previousIsVowel = false;
	      var previousIsStrongVowel = false; // only valid if previousIsVowel == true
	      var startSyllable = 0;
	
	      // fixme: first check for prefixes
	
	      for (i = 0; i < word.length; i++) {
	
	        var c = word[i].toLowerCase();
	
	        if (this.isVowel(c)) {
	
	          // we have a complete syllable as soon as we have a vowel
	          haveCompleteSyllable = true;
	
	          var cIsStrongVowel = this.isStrongVowel(c);
	
	          if (previousIsVowel) {
	            // if we're at a strong vowel, then we finish out the last syllable
	            if (cIsStrongVowel) {
	              if (previousIsStrongVowel) {
	                syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable)));
	                startSyllable = i;
	              }
	            }
	          }
	
	          previousIsVowel = true;
	          previousIsStrongVowel = cIsStrongVowel;
	        } else {
	          if (!haveCompleteSyllable) {
	            // do nothing since we don't have a complete syllable yet...
	          } else {
	
	              // handle explicit syllable breaks
	              if (word[i] === '-') {
	                // start new syllable
	                syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable)));
	                startSyllable = ++i;
	              } else {
	
	                var numberOfConsonants = 1,
	                    consonant2;
	
	                // count how many more consonants there are
	                for (j = i + 1; j < word.length; j++) {
	                  if (this.isVowel(word[j])) break;
	                  numberOfConsonants++;
	                }
	
	                if (numberOfConsonants === 1) {
	                  // start new syllable
	                  syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable)));
	                  startSyllable = i;
	                } else if (numberOfConsonants === 2) {
	                  consonant2 = word[i + 1].toLowerCase();
	                  if (consonant2 === 'l' || consonant2 === 'r' || c === 'c' && consonant2 === 'h') {
	                    // split before the consonant pair
	                    syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable)));
	                    startSyllable = i++;
	                  } else {
	                    //split the consonants
	                    syllables.push(this.createSyllable(word.substr(startSyllable, ++i - startSyllable)));
	                    startSyllable = i;
	                  }
	                } else if (numberOfConsonants === 3) {
	                  consonant2 = word[i + 1].toLowerCase();
	
	                  // if second consonant is s, divide cc-c, otherwise divide c-cc
	                  if (consonant2 === 's') {
	                    i += 2;
	                    syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable)));
	                  } else syllables.push(this.createSyllable(word.substr(startSyllable, ++i - startSyllable)));
	
	                  startSyllable = i;
	                } else if (numberOfConsonants === 4) {
	                  // four always get split cc-cc
	                  syllables.push(this.createSyllable(word.substr(startSyllable, i - startSyllable + 2)));
	                  startSyllable = i + 2;
	                  i += 3;
	                }
	              }
	
	              haveCompleteSyllable = false;
	            }
	
	          previousIsVowel = false;
	        }
	      }
	
	      // if we have a complete syllable, we can add it as a new one. Otherwise
	      // we tack the remaining characters onto the last syllable.
	      if (haveCompleteSyllable) syllables.push(word.substr(startSyllable));else if (startSyllable > 0) syllables[syllables.length - 1] += word.substr(startSyllable);else if (syllables.length === 0) syllables.push(this.createSyllable(word));
	
	      return syllables;
	    }
	
	    /**
	     * @param {String} s the string to search
	     * @param {Number} startIndex The index at which to start searching for a vowel in the string
	     * @retuns a custom class with three properties: {found: (true/false) startIndex: (start index in s of vowel segment) length ()}
	     */
	
	  }, {
	    key: 'findVowelSegment',
	    value: function findVowelSegment(s, startIndex) {
	
	      var i, end, index;
	      var workingString = s.toLowerCase();
	
	      // do we have a diphthongs?
	      for (i = 0, end = this.diphthongs.length; i < end; i++) {
	        var d = this.diphthongs[i];
	        index = workingString.indexOf(d, startIndex);
	
	        if (index >= 0) {
	
	          // check the exceptions...
	          if (d[0] === 'u' && index > 0) {
	            var tripthong = s.substr(index - 1, 3).toLowerCase();
	
	            for (j = 0, endj = this.uDiphthongExceptions.length; i < endj; j++) {
	              if (tripthong === this.uDiphthongExceptions[j]) {
	                // search from after the u...
	                return this.findVowelSegment(s, index + 1);
	              }
	            }
	          }
	
	          return { found: true, startIndex: index, length: d.length };
	        }
	      }
	
	      // no diphthongs. Let's look for single vowels then...
	      for (i = 0, end = this.vowels.length; i < end; i++) {
	        index = workingString.indexOf(this.vowels[i], startIndex);
	
	        if (index >= 0) return { found: true, startIndex: index, length: 1 };
	      }
	
	      // no vowels sets found after startIndex!
	      return { found: false, startIndex: -1, length: -1 };
	    }
	  }]);
	
	  return Spanish;
	}(Language);

/***/ },
/* 3 */
/***/ function(module, exports) {

	"use strict";
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	//
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	// generated based on the svg data
	var Glyphs = exports.Glyphs = {
	  "None": {
	    "svgSrc": "<g></g>",
	    "paths": [{
	      "type": "positive",
	      "data": ""
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 0,
	      "height": 0
	    },
	    "origin": {
	      "x": 0,
	      "y": 0
	    },
	    "align": "left"
	  },
	  "AcuteAccent": {
	    "svgSrc": "<path d=\"M4 0C-.614.52-.614.52-.803-3.182l60.768-108.422c4.52-7.182 10.543-13.67 18.075-13.67 5.27 0 14.31 1.264 23.346 7.793 7.53 5.223 8.803 11.752 8.803 16.975 0 3.917-.52 11.1-8.05 17.628L4 0z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M4 0C-.614.52-.614.52-.803-3.182l60.768-108.422c4.52-7.182 10.543-13.67 18.075-13.67 5.27 0 14.31 1.264 23.346 7.793 7.53 5.223 8.803 11.752 8.803 16.975 0 3.917-.52 11.1-8.05 17.628L4 0z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 110.99200439453125,
	      "height": 125.79399108886719
	    },
	    "origin": {
	      "x": 0.8030000329017639,
	      "y": 125.27399444580078
	    },
	    "align": "left"
	  },
	  "Stropha": {
	    "svgSrc": "<path d=\"M1.22-73.438c4.165 13.02 12.238 27.084 24.217 42.188L49.657 0 34.812 27.344C18.666 55.47-.084 72.396-21.438 78.124c4.687-3.645 7.03-8.593 7.03-14.843 0-8.853-4.947-20.572-14.843-35.155L-48 0 1.22-73.438z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M1.22-73.438c4.165 13.02 12.238 27.084 24.217 42.188L49.657 0 34.812 27.344C18.666 55.47-.084 72.396-21.438 78.124c4.687-3.645 7.03-8.593 7.03-14.843 0-8.853-4.947-20.572-14.843-35.155L-48 0 1.22-73.438z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 97.65699768066406,
	      "height": 151.56201171875
	    },
	    "origin": {
	      "x": 48,
	      "y": 73.43800354003906
	    },
	    "align": "left"
	  },
	  "BeginningAscLiquescent": {
	    "svgSrc": "<path d=\"M-50 43.688V-61c4.167 7.292 12.76 10.938 25.78 10.938 9.376 0 20.053-1.563 32.032-4.688C31.773-60.48 45.833-71.677 50-88.344v117.97C43.75 42.645 32.812 51.5 17.187 56.186-.52 61.398-15.886 64-28.906 64-42.97 64-50 57.23-50 43.687z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50 43.688V-61c4.167 7.292 12.76 10.938 25.78 10.938 9.376 0 20.053-1.563 32.032-4.688C31.773-60.48 45.833-71.677 50-88.344v117.97C43.75 42.645 32.812 51.5 17.187 56.186-.52 61.398-15.886 64-28.906 64-42.97 64-50 57.23-50 43.687z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 152.343994140625
	    },
	    "origin": {
	      "x": 50,
	      "y": 88.34400177001953
	    },
	    "align": "left"
	  },
	  "BeginningDesLiquescent": {
	    "svgSrc": "<path d=\"M-50-56.03c0-13.022 7.03-19.532 21.094-19.532 13.02 0 28.385 2.604 46.093 7.812C32.813-63.583 43.75-54.73 50-41.187V76C45.833 59.854 31.77 48.656 7.812 42.406c-11.98-3.125-22.656-4.687-32.03-4.687-13.022 0-21.615 3.905-25.782 11.718v-105.47z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50-56.03c0-13.022 7.03-19.532 21.094-19.532 13.02 0 28.385 2.604 46.093 7.812C32.813-63.583 43.75-54.73 50-41.187V76C45.833 59.854 31.77 48.656 7.812 42.406c-11.98-3.125-22.656-4.687-32.03-4.687-13.022 0-21.615 3.905-25.782 11.718v-105.47z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 151.56199645996094
	    },
	    "origin": {
	      "x": 50,
	      "y": 75.56199645996094
	    },
	    "align": "left"
	  },
	  "CustosDescLong": {
	    "svgSrc": "<path d=\"M39.063 273.472c5.73.52 7.29-6.25 4.687-20.312V-65.59c-13.542 2.083-24.22 5.468-32.03 10.156C3.905-50.226 0-43.714 0-35.904V71.91c5.73-5.21 10.677-8.594 14.844-10.157 5.73-1.562 12.24-2.343 19.53-2.343v196.875c0 11.458 1.563 17.187 4.688 17.187z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M39.063 273.472c5.73.52 7.29-6.25 4.687-20.312V-65.59c-13.542 2.083-24.22 5.468-32.03 10.156C3.905-50.226 0-43.714 0-35.904V71.91c5.73-5.21 10.677-8.594 14.844-10.157 5.73-1.562 12.24-2.343 19.53-2.343v196.875c0 11.458 1.563 17.187 4.688 17.187"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 46.35300064086914,
	      "height": 339.58197021484375
	    },
	    "origin": {
	      "x": 0,
	      "y": 65.58999633789062
	    },
	    "align": "left"
	  },
	  "CustosDescShort": {
	    "svgSrc": "<path d=\"M34.375 191.923c0 8.333 1.563 12.24 4.688 11.72 3.125-.522 4.687-7.033 4.687-19.533v-250c-13.542 2.084-24.22 5.47-32.03 10.157C3.905-50.525 0-44.015 0-36.203V71.61c5.73-5.208 10.677-8.593 14.844-10.156 5.73-1.562 12.24-2.344 19.53-2.344v132.813z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M34.375 191.923c0 8.333 1.563 12.24 4.688 11.72 3.125-.522 4.687-7.033 4.687-19.533v-250c-13.542 2.084-24.22 5.47-32.03 10.157C3.905-50.525 0-44.015 0-36.203V71.61c5.73-5.208 10.677-8.593 14.844-10.156 5.73-1.562 12.24-2.344 19.53-2.344v132.813z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 43.75,
	      "height": 270.0530090332031
	    },
	    "origin": {
	      "x": 0,
	      "y": 65.88999938964844
	    },
	    "align": "left"
	  },
	  "CustosLong": {
	    "svgSrc": "<path d=\"M39.063-269.562c5.73-.52 7.29 6.25 4.687 20.312V69.5c-13.542-2.083-24.22-5.47-32.03-10.156C3.905 54.134 0 47.624 0 39.812V-68c5.73 5.208 10.677 8.594 14.844 10.156 5.73 1.563 12.24 2.344 19.53 2.344v-196.875c0-11.458 1.563-17.187 4.688-17.187z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M39.063-269.562c5.73-.52 7.29 6.25 4.687 20.312V69.5c-13.542-2.083-24.22-5.47-32.03-10.156C3.905 54.134 0 47.624 0 39.812V-68c5.73 5.208 10.677 8.594 14.844 10.156 5.73 1.563 12.24 2.344 19.53 2.344v-196.875c0-11.458 1.563-17.187 4.688-17.187z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 46.35300064086914,
	      "height": 339.5820007324219
	    },
	    "origin": {
	      "x": 0,
	      "y": 270.0820007324219
	    },
	    "align": "left"
	  },
	  "CustosShort": {
	    "svgSrc": "<path d=\"M34.375-188.125c0-8.333 1.563-12.24 4.688-11.72 3.125.522 4.687 7.033 4.687 19.532v250c-13.542-2.083-24.22-5.468-32.03-10.156C3.905 54.324 0 47.813 0 40V-67.813c5.73 5.21 10.677 8.594 14.844 10.157 5.73 1.562 12.24 2.344 19.53 2.343v-132.812z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M34.375-188.125c0-8.333 1.563-12.24 4.688-11.72 3.125.522 4.687 7.033 4.687 19.532v250c-13.542-2.083-24.22-5.468-32.03-10.156C3.905 54.324 0 47.813 0 40V-67.813c5.73 5.21 10.677 8.594 14.844 10.157 5.73 1.562 12.24 2.344 19.53 2.343v-132.812z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 43.75,
	      "height": 270.052001953125
	    },
	    "origin": {
	      "x": 0,
	      "y": 200.36500549316406
	    },
	    "align": "left"
	  },
	  "DoClef": {
	    "svgSrc": "<path d=\"M0 98.406V-97.688C0-118 5.99-134.275 17.97-146.516c11.978-12.24 27.603-18.36 46.874-18.36 10.937 0 19.53 3.126 25.78 9.376s9.376 14.583 9.376 25v107.813l-6.25-5.47c-4.167-3.645-10.287-7.42-18.36-11.327-8.072-3.907-16.796-5.86-26.17-5.86-11.46 0-21.486 4.427-30.08 13.282-8.593 8.854-12.89 19.53-12.89 32.03s4.297 23.308 12.89 32.423c8.594 9.115 18.62 13.672 30.08 13.672 9.374 0 18.098-1.822 26.17-5.468 8.073-3.646 14.193-7.292 18.36-10.938l6.25-6.25V132c0 9.896-3.125 18.1-9.375 24.61-6.25 6.51-14.844 9.765-25.78 9.765-19.272 0-34.897-6.25-46.876-18.75C5.99 135.125 0 118.72 0 98.405z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M0 98.406V-97.688C0-118 5.99-134.275 17.97-146.516c11.978-12.24 27.603-18.36 46.874-18.36 10.937 0 19.53 3.126 25.78 9.376s9.376 14.583 9.376 25v107.813l-6.25-5.47c-4.167-3.645-10.287-7.42-18.36-11.327-8.072-3.907-16.796-5.86-26.17-5.86-11.46 0-21.486 4.427-30.08 13.282-8.593 8.854-12.89 19.53-12.89 32.03s4.297 23.308 12.89 32.423c8.594 9.115 18.62 13.672 30.08 13.672 9.374 0 18.098-1.822 26.17-5.468 8.073-3.646 14.193-7.292 18.36-10.938l6.25-6.25V132c0 9.896-3.125 18.1-9.375 24.61-6.25 6.51-14.844 9.765-25.78 9.765-19.272 0-34.897-6.25-46.876-18.75C5.99 135.125 0 118.72 0 98.405z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 331.2510070800781
	    },
	    "origin": {
	      "x": 0,
	      "y": 164.87600708007812
	    },
	    "align": "left"
	  },
	  "FaClef": {
	    "svgSrc": "<path d=\"M85.156-32v193.75c0 9.375-1.562 14.323-4.687 14.844-1.564 0-2.605-.52-3.126-1.563-.52-1.04-.782-2.603-.78-4.686V56.28c-8.335-8.332-19.793-12.5-34.376-12.5-17.71 0-31.77 3.907-42.188 11.72V-32c0-18.23 14.193-27.344 42.578-27.344 28.385 0 42.578 9.115 42.578 27.344zM98.438 93V-92.156c0-19.27 5.73-34.896 17.187-46.875 11.458-11.98 26.562-17.97 45.313-17.97 10.937 0 19.14 2.865 24.61 8.594 5.467 5.73 8.202 13.542 8.202 23.437v103.126l-5.47-4.687c-3.645-3.647-9.374-7.293-17.186-10.94-7.813-3.645-15.886-5.467-24.22-5.468-11.978 0-22.004 4.167-30.077 12.5-8.073 8.334-12.11 18.36-12.11 30.08 0 11.717 4.037 22.004 12.11 30.858s18.1 13.28 30.078 13.28c8.333 0 16.406-1.822 24.22-5.468 7.81-3.645 13.54-7.03 17.186-10.156l5.47-5.468V125.81c0 9.896-2.865 17.84-8.594 23.83-5.73 5.988-13.802 8.983-24.22 8.983-18.75 0-33.853-6.12-45.31-18.36-11.46-12.24-17.19-27.994-17.19-47.265z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M85.156-32v193.75c0 9.375-1.562 14.323-4.687 14.844-1.564 0-2.605-.52-3.126-1.563-.52-1.04-.782-2.603-.78-4.686V56.28c-8.335-8.332-19.793-12.5-34.376-12.5-17.71 0-31.77 3.907-42.188 11.72V-32c0-18.23 14.193-27.344 42.578-27.344 28.385 0 42.578 9.115 42.578 27.344zM98.438 93V-92.156c0-19.27 5.73-34.896 17.187-46.875 11.458-11.98 26.562-17.97 45.313-17.97 10.937 0 19.14 2.865 24.61 8.594 5.467 5.73 8.202 13.542 8.202 23.437v103.126l-5.47-4.687c-3.645-3.647-9.374-7.293-17.186-10.94-7.813-3.645-15.886-5.467-24.22-5.468-11.978 0-22.004 4.167-30.077 12.5-8.073 8.334-12.11 18.36-12.11 30.08 0 11.717 4.037 22.004 12.11 30.858s18.1 13.28 30.078 13.28c8.333 0 16.406-1.822 24.22-5.468 7.81-3.645 13.54-7.03 17.186-10.156l5.47-5.468V125.81c0 9.896-2.865 17.84-8.594 23.83-5.73 5.988-13.802 8.983-24.22 8.983-18.75 0-33.853-6.12-45.31-18.36-11.46-12.24-17.19-27.994-17.19-47.265z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 193.75201416015625,
	      "height": 333.5950012207031
	    },
	    "origin": {
	      "x": 0.001003265380859375,
	      "y": 157.00100708007812
	    },
	    "align": "left"
	  },
	  "Flat": {
	    "svgSrc": "<path d=\"M7.813-204.406c4.166 0 6.25 5.208 6.25 15.625L12.5-10.657C33.854 13.302 54.167 25.28 73.438 25.28c9.374 0 14.062-4.686 14.062-14.06 0-6.25-1.042-11.72-3.125-16.407-2.083-4.688-7.03-9.766-14.844-15.235-7.81-5.47-13.02-8.984-15.624-10.547L27.344-45.81V-80.97c17.187 0 33.073 4.82 47.656 14.454C89.583-56.88 96.875-47.376 96.875-38c0 67.708-.26 101.562-.78 101.563-38.543 0-69.532-12.24-92.97-36.72C0-52.322-1.042-123.936 0-188c0-10.937 2.604-16.406 7.813-16.406z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M7.813-204.406c4.166 0 6.25 5.208 6.25 15.625L12.5-10.657C33.854 13.302 54.167 25.28 73.438 25.28c9.374 0 14.062-4.686 14.062-14.06 0-6.25-1.042-11.72-3.125-16.407-2.083-4.688-7.03-9.766-14.844-15.235-7.81-5.47-13.02-8.984-15.624-10.547L27.344-45.81V-80.97c17.187 0 33.073 4.82 47.656 14.454C89.583-56.88 96.875-47.376 96.875-38c0 67.708-.26 101.562-.78 101.563-38.543 0-69.532-12.24-92.97-36.72C0-52.322-1.042-123.936 0-188c0-10.937 2.604-16.406 7.813-16.406z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 97.91699981689453,
	      "height": 267.968994140625
	    },
	    "origin": {
	      "x": 1.0420000553131104,
	      "y": 204.406005859375
	    },
	    "align": "left"
	  },
	  "Mora": {
	    "svgSrc": "<path d=\"M47.478-24c6.957 0 12.793 2.288 17.49 6.883C69.662-12.52 72-6.904 72-.267c0 6.64-2.337 12.352-7.033 17.118C60.27 21.618 54.435 24 47.477 24c-6.26 0-11.748-2.383-16.444-7.15C26.337 12.086 24 6.374 24-.265c0-6.638 2.337-12.255 7.033-16.85C35.73-21.713 41.217-24 47.478-24z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M47.478-24c6.957 0 12.793 2.288 17.49 6.883C69.662-12.52 72-6.904 72-.267c0 6.64-2.337 12.352-7.033 17.118C60.27 21.618 54.435 24 47.477 24c-6.26 0-11.748-2.383-16.444-7.15C26.337 12.086 24 6.374 24-.265c0-6.638 2.337-12.255 7.033-16.85C35.73-21.713 41.217-24 47.478-24z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 48,
	      "height": 48
	    },
	    "origin": {
	      "x": -24,
	      "y": 24
	    },
	    "align": "left"
	  },
	  "Natural": {
	    "svgSrc": "<path d=\"M7.906-166.563c-2.864 0-5.614.52-8.218 1.563v13.28l.78 56.25.782 78.907v85.157c.52 3.646 2.604 5.73 6.25 6.25l23.438-3.906 23.437-3.907v29.69c0 42.186-.26 63.54-.78 64.06l6.25 2.345c1.04.52 2.082.78 3.124.78 2.603 0 4.947-1.3 7.03-3.905L67.656-71.25c-.52-2.604-2.083-3.906-4.687-3.906-7.814 0-17.19 1.04-28.126 3.125l-19.53 3.124.78-38.28V-165c-2.604-1.042-5.323-1.562-8.188-1.563zM55.938-40v71.875l-41.407 7.03c0-48.436.262-72.655.783-72.655L55.938-40z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M7.906-166.563c-2.864 0-5.614.52-8.218 1.563v13.28l.78 56.25.782 78.907v85.157c.52 3.646 2.604 5.73 6.25 6.25l23.438-3.906 23.437-3.907v29.69c0 42.186-.26 63.54-.78 64.06l6.25 2.345c1.04.52 2.082.78 3.124.78 2.603 0 4.947-1.3 7.03-3.905L67.656-71.25c-.52-2.604-2.083-3.906-4.687-3.906-7.814 0-17.19 1.04-28.126 3.125l-19.53 3.124.78-38.28V-165c-2.604-1.042-5.323-1.562-8.188-1.563zM55.938-40v71.875l-41.407 7.03c0-48.436.262-72.655.783-72.655L55.938-40z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 70.31100463867188,
	      "height": 330.468994140625
	    },
	    "origin": {
	      "x": 0.3120002746582031,
	      "y": 166.56300354003906
	    },
	    "align": "left"
	  },
	  "OriscusAsc": {
	    "svgSrc": "<path d=\"M50 30.25c0 12.5-3.125 21.354-9.375 26.562-3.125 2.605-7.813 3.907-14.063 3.907-3.125 0-5.99-.522-8.593-1.564-2.605-1.04-5.6-2.474-8.986-4.297C5.6 53.035 2.734 51.603.39 50.56c-2.343-1.04-5.338-2.474-8.984-4.296-3.646-1.823-6.77-3.256-9.375-4.297-2.603-1.043-5.468-1.564-8.593-1.564-6.25 0-10.937 1.563-14.062 4.688C-46.875 50.824-50 59.677-50 71.656v-106.25c0-13.02 3.125-21.875 9.375-26.562 3.125-2.604 7.813-3.906 14.063-3.907 3.125 0 5.99.52 8.593 1.563 2.605 1.042 5.73 2.474 9.376 4.297 3.646 1.823 6.51 2.995 8.594 3.516l10.938 5.468c6.25 3.126 11.458 4.69 15.624 4.69 6.25 0 10.938-1.564 14.063-4.69C46.875-55.426 50-64.02 50-76V30.25z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M50 30.25c0 12.5-3.125 21.354-9.375 26.562-3.125 2.605-7.813 3.907-14.063 3.907-3.125 0-5.99-.522-8.593-1.564-2.605-1.04-5.6-2.474-8.986-4.297C5.6 53.035 2.734 51.603.39 50.56c-2.343-1.04-5.338-2.474-8.984-4.296-3.646-1.823-6.77-3.256-9.375-4.297-2.603-1.043-5.468-1.564-8.593-1.564-6.25 0-10.937 1.563-14.062 4.688C-46.875 50.824-50 59.677-50 71.656v-106.25c0-13.02 3.125-21.875 9.375-26.562 3.125-2.604 7.813-3.906 14.063-3.907 3.125 0 5.99.52 8.593 1.563 2.605 1.042 5.73 2.474 9.376 4.297 3.646 1.823 6.51 2.995 8.594 3.516l10.938 5.468c6.25 3.126 11.458 4.69 15.624 4.69 6.25 0 10.938-1.564 14.063-4.69C46.875-55.426 50-64.02 50-76V30.25z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 147.656005859375
	    },
	    "origin": {
	      "x": 50,
	      "y": 76
	    },
	    "align": "left"
	  },
	  "OriscusDes": {
	    "svgSrc": "<path d=\"M-50 30.844v-106.25c0 11.458 3.125 20.052 9.375 25.78 3.125 3.126 7.813 4.69 14.063 4.688 4.687 0 13.41-3.255 26.17-9.765 12.762-6.51 21.746-9.766 26.954-9.766 6.25 0 10.938 1.303 14.063 3.907C46.875-55.874 50-47.02 50-34V72.25c0-11.98-3.125-20.833-9.375-26.563C37.5 42.563 32.812 41 26.562 41 21.875 41 13.023 44.385 0 51.156c-4.167 2.604-8.594 4.948-13.28 7.032-4.69 2.083-9.116 3.124-13.283 3.124-6.25 0-10.937-1.302-14.062-3.906C-46.875 52.198-50 43.344-50 30.844z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50 30.844v-106.25c0 11.458 3.125 20.052 9.375 25.78 3.125 3.126 7.813 4.69 14.063 4.688 4.687 0 13.41-3.255 26.17-9.765 12.762-6.51 21.746-9.766 26.954-9.766 6.25 0 10.938 1.303 14.063 3.907C46.875-55.874 50-47.02 50-34V72.25c0-11.98-3.125-20.833-9.375-26.563C37.5 42.563 32.812 41 26.562 41 21.875 41 13.023 44.385 0 51.156c-4.167 2.604-8.594 4.948-13.28 7.032-4.69 2.083-9.116 3.124-13.283 3.124-6.25 0-10.937-1.302-14.062-3.906C-46.875 52.198-50 43.344-50 30.844z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 147.656005859375
	    },
	    "origin": {
	      "x": 50,
	      "y": 75.40599822998047
	    },
	    "align": "left"
	  },
	  "OriscusLiquescent": {
	    "svgSrc": "<path d=\"M 19.05539,78.886528 C 20.242277,78.486807 21.532179,77.890297 22.925106,77.09701 24.317891,76.303653 26.700882,74.417241 30.074091,71.437777 33.447144,68.45824 36.523539,64.985185 39.303286,61.018598 42.082855,57.051975 44.562739,51.395765 46.742952,44.049969 48.922975,36.704172 50.01304,28.671032 50.013135,19.950525 L 50.013135,-34.225545 C 50.01304,-54.464261 42.07377,-64.583661 26.195289,-64.583768 20.248326,-64.583661 11.518758,-61.410372 0.00656131,-55.06389 -11.505742,-48.717218 -20.23531,-45.543929 -26.182179,-45.544024 -34.515109,-45.543929 -40.567968,-48.520405 -44.340791,-54.473441 -48.113613,-60.426286 -50.000025,-67.369373 -50.000025,-75.302702 L -50.000025,30.069925 C -50.000025,49.909039 -42.060754,59.828603 -26.182179,59.828615 -21.022584,59.828603 -12.38991,56.455465 -0.28412107,49.709203 11.821549,42.96294 20.648023,39.589803 26.195289,39.589803 29.368506,40.776762 30.361665,44.249817 29.17479,50.00897 27.987759,55.768122 26.00143,62.020829 23.215789,68.767116 z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M 19.05539,78.886528 C 20.242277,78.486807 21.532179,77.890297 22.925106,77.09701 24.317891,76.303653 26.700882,74.417241 30.074091,71.437777 33.447144,68.45824 36.523539,64.985185 39.303286,61.018598 42.082855,57.051975 44.562739,51.395765 46.742952,44.049969 48.922975,36.704172 50.01304,28.671032 50.013135,19.950525 L 50.013135,-34.225545 C 50.01304,-54.464261 42.07377,-64.583661 26.195289,-64.583768 20.248326,-64.583661 11.518758,-61.410372 0.00656131,-55.06389 -11.505742,-48.717218 -20.23531,-45.543929 -26.182179,-45.544024 -34.515109,-45.543929 -40.567968,-48.520405 -44.340791,-54.473441 -48.113613,-60.426286 -50.000025,-67.369373 -50.000025,-75.302702 L -50.000025,30.069925 C -50.000025,49.909039 -42.060754,59.828603 -26.182179,59.828615 -21.022584,59.828603 -12.38991,56.455465 -0.28412107,49.709203 11.821549,42.96294 20.648023,39.589803 26.195289,39.589803 29.368506,40.776762 30.361665,44.249817 29.17479,50.00897 27.987759,55.768122 26.00143,62.020829 23.215789,68.767116 z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 147.656005859375
	    },
	    "origin": {
	      "x": 50,
	      "y": 75.40599822998047
	    },
	    "align": "left"
	  },
	  "PodatusLower": {
	    "svgSrc": "<path d=\"M-4.688-30.28c22.396 0 34.636-.262 36.72-.782 5.728-1.563 8.593-5.21 8.593-10.938H50v97.656c0 2.604-1.302 4.167-3.906 4.688-5.21.52-21.355.78-48.438.78-23.958 0-38.54-.26-43.75-.78-2.604 0-3.906-1.302-3.906-3.906v-82.032c0-3.646 1.302-5.468 3.906-5.468h2.344c2.604.52 15.625.78 39.063.78z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-4.688-30.28c22.396 0 34.636-.262 36.72-.782 5.728-1.563 8.593-5.21 8.593-10.938H50v97.656c0 2.604-1.302 4.167-3.906 4.688-5.21.52-21.355.78-48.438.78-23.958 0-38.54-.26-43.75-.78-2.604 0-3.906-1.302-3.906-3.906v-82.032c0-3.646 1.302-5.468 3.906-5.468h2.344c2.604.52 15.625.78 39.063.78z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 103.12399291992188
	    },
	    "origin": {
	      "x": 50,
	      "y": 42
	    },
	    "align": "left"
	  },
	  "PodatusUpper": {
	    "svgSrc": "<path d=\"M-46.094-63.78c13.542 0 24.61 2.473 33.203 7.42C-4.298-51.41 0-43.99 0-34.093V62h-9.375c0-10.938-2.604-19.14-7.812-24.61-5.21-5.468-14.844-8.203-28.907-8.202-18.23 0-33.333 4.166-45.312 12.5v-75.782c0-19.79 15.104-29.687 45.312-29.687z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-46.094-63.78c13.542 0 24.61 2.473 33.203 7.42C-4.298-51.41 0-43.99 0-34.093V62h-9.375c0-10.938-2.604-19.14-7.812-24.61-5.21-5.468-14.844-8.203-28.907-8.202-18.23 0-33.333 4.166-45.312 12.5v-75.782c0-19.79 15.104-29.687 45.312-29.687z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 91.406005859375,
	      "height": 125.78099822998047
	    },
	    "origin": {
	      "x": 91.406005859375,
	      "y": 63.78099822998047
	    },
	    "align": "right"
	  },
	  "Porrectus1": {
	    "svgSrc": "<path d=\"M233.594 162.875c-58.855 0-107.032-6.25-144.53-18.75C34.895 125.895-11.46 99.855-50 66V-52.75C-21.354-24.625 26.302 6.885 92.97 41.78 123.697 57.928 163.54 66 212.5 66c21.354 0 34.635-9.896 39.844-29.688V151.94c0 7.29-6.25 10.937-18.75 10.937z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M233.594 162.875c-58.855 0-107.032-6.25-144.53-18.75C34.895 125.895-11.46 99.855-50 66V-52.75C-21.354-24.625 26.302 6.885 92.97 41.78 123.697 57.928 163.54 66 212.5 66c21.354 0 34.635-9.896 39.844-29.688V151.94c0 7.29-6.25 10.937-18.75 10.937z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 302.343994140625,
	      "height": 215.6269989013672
	    },
	    "origin": {
	      "x": 50,
	      "y": 52.75
	    },
	    "align": "left"
	  },
	  "Porrectus2": {
	    "svgSrc": "<path d=\"M309.375 259.375c-50.52 0-110.938-22.396-181.25-67.188C48.437 141.667-10.938 94.272-50 50V-68.75C0-3.125 60.417 52.083 131.25 96.875c58.333 36.98 110.677 58.854 157.03 65.625h7.033c16.145 0 26.822-9.896 32.03-29.688v114.844c0 7.812-5.99 11.72-17.968 11.72z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M309.375 259.375c-50.52 0-110.938-22.396-181.25-67.188C48.437 141.667-10.938 94.272-50 50V-68.75C0-3.125 60.417 52.083 131.25 96.875c58.333 36.98 110.677 58.854 157.03 65.625h7.033c16.145 0 26.822-9.896 32.03-29.688v114.844c0 7.812-5.99 11.72-17.968 11.72z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 377.3429870605469,
	      "height": 328.1260070800781
	    },
	    "origin": {
	      "x": 50,
	      "y": 68.75
	    },
	    "align": "left"
	  },
	  "Porrectus3": {
	    "svgSrc": "<path d=\"M309.375 355.78c-48.96-16.666-109.115-55.468-180.47-116.405C79.428 198.23 19.793 134.687-50 48.75V-70C20 40 94.104 103.79 135.25 148.063 190 200 230 230 288.28 258.906c4.168 2.083 8.334 3.125 12.5 3.125 12.5 0 21.355-10.937 26.564-32.81v114.06c0 9.376-3.386 14.063-10.156 14.064-2.084 0-4.688-.522-7.813-1.563z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M309.375 355.78c-48.96-16.666-109.115-55.468-180.47-116.405C79.428 198.23 19.793 134.687-50 48.75V-70C20 40 94.104 103.79 135.25 148.063 190 200 230 230 288.28 258.906c4.168 2.083 8.334 3.125 12.5 3.125 12.5 0 21.355-10.937 26.564-32.81v114.06c0 9.376-3.386 14.063-10.156 14.064-2.084 0-4.688-.522-7.813-1.563z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 377.343994140625,
	      "height": 427.3450012207031
	    },
	    "origin": {
	      "x": 50,
	      "y": 70
	    },
	    "align": "left"
	  },
	  "Porrectus4": {
	    "svgSrc": "<path d=\"M350 453.438c-52.754-22.397-120-77.345-201.74-164.844C90.87 227.656 24.784 147.708-50 48.75V-70C-8.84-1.25 58.406 86.51 151.74 193.28c60.868 69.793 119.13 124.22 174.782 163.282 5.797 3.646 11.014 5.47 15.652 5.47 12.173 0 21.45-11.72 27.826-35.157V441.72c0 9.373-3.19 14.06-9.565 14.06-2.9 0-6.377-.78-10.435-2.342z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M350 453.438c-52.754-22.397-120-77.345-201.74-164.844C90.87 227.656 24.784 147.708-50 48.75V-70C-8.84-1.25 58.406 86.51 151.74 193.28c60.868 69.793 119.13 124.22 174.782 163.282 5.797 3.646 11.014 5.47 15.652 5.47 12.173 0 21.45-11.72 27.826-35.157V441.72c0 9.373-3.19 14.06-9.565 14.06-2.9 0-6.377-.78-10.435-2.342z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 420,
	      "height": 525.780029296875
	    },
	    "origin": {
	      "x": 50,
	      "y": 70
	    },
	    "align": "left"
	  },
	  "PunctumCavum": {
	    "svgSrc": "<path d=\"M0-60.906c33.333 0 50 9.635 50 28.906v94.53C39.062 51.595 22.396 46.126 0 46.126s-39.063 5.47-50 16.406V-32c0-19.27 16.667-28.906 50-28.906z\"/><path fill=\"#fff\" d=\"M.08-42.56c9.585.206 20.126.53 27.954 6.822 4.96 3.9 4.71 10.792 4.574 16.482v51.278C22.09 27.066 7.283 26.072.168 26.01c-7.72.23-21.895.935-32.616 4.674.04-19.197-.083-38.395.064-57.59.567-7.5 7.834-12.33 14.62-13.774 5.818-1.498 11.857-1.86 17.844-1.88z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M0-60.906c33.333 0 50 9.635 50 28.906v94.53C39.062 51.595 22.396 46.126 0 46.126s-39.063 5.47-50 16.406V-32c0-19.27 16.667-28.906 50-28.906z"
	    }, {
	      "type": "negative",
	      "data": "M.08-42.56c9.585.206 20.126.53 27.954 6.822 4.96 3.9 4.71 10.792 4.574 16.482v51.278C22.09 27.066 7.283 26.072.168 26.01c-7.72.23-21.895.935-32.616 4.674.04-19.197-.083-38.395.064-57.59.567-7.5 7.834-12.33 14.62-13.774 5.818-1.498 11.857-1.86 17.844-1.88z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 123.43799591064453
	    },
	    "origin": {
	      "x": 50,
	      "y": 60.90599822998047
	    },
	    "align": "left"
	  },
	  "PunctumQuadratum": {
	    "svgSrc": "<path d=\"M0-60.906c33.333 0 50 9.635 50 28.906v94.53C39.062 51.595 22.396 46.126 0 46.126s-39.063 5.47-50 16.406V-32c0-19.27 16.667-28.906 50-28.906z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M0-60.906c33.333 0 50 9.635 50 28.906v94.53C39.062 51.595 22.396 46.126 0 46.126s-39.063 5.47-50 16.406V-32c0-19.27 16.667-28.906 50-28.906z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 123.43799591064453
	    },
	    "origin": {
	      "x": 50,
	      "y": 60.90599822998047
	    },
	    "align": "left"
	  },
	  "PunctumQuadratumAscLiquescent": {
	    "svgSrc": "<path d=\"M-50 43.688V-61c4.167 7.292 12.76 10.938 25.78 10.938 9.376 0 20.053-1.563 32.032-4.688C31.773-60.48 45.833-71.677 50-88.344v117.97C43.75 42.645 32.812 51.5 17.187 56.186-.52 61.398-15.886 64-28.906 64-42.97 64-50 57.23-50 43.687z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50 43.688V-61c4.167 7.292 12.76 10.938 25.78 10.938 9.376 0 20.053-1.563 32.032-4.688C31.773-60.48 45.833-71.677 50-88.344v117.97C43.75 42.645 32.812 51.5 17.187 56.186-.52 61.398-15.886 64-28.906 64-42.97 64-50 57.23-50 43.687z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 152.343994140625
	    },
	    "origin": {
	      "x": 50,
	      "y": 88.34400177001953
	    },
	    "align": "left"
	  },
	  "PunctumQuadratumDesLiquescent": {
	    "svgSrc": "<path d=\"M-50-56.03c0-13.022 7.03-19.532 21.094-19.532 13.02 0 28.385 2.604 46.093 7.812C32.813-63.583 43.75-54.73 50-41.187V76C45.833 59.854 31.77 48.656 7.812 42.406c-11.98-3.125-22.656-4.687-32.03-4.687-13.022 0-21.615 3.905-25.782 11.718v-105.47z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50-56.03c0-13.022 7.03-19.532 21.094-19.532 13.02 0 28.385 2.604 46.093 7.812C32.813-63.583 43.75-54.73 50-41.187V76C45.833 59.854 31.77 48.656 7.812 42.406c-11.98-3.125-22.656-4.687-32.03-4.687-13.022 0-21.615 3.905-25.782 11.718v-105.47z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 151.56199645996094
	    },
	    "origin": {
	      "x": 50,
	      "y": 75.56199645996094
	    },
	    "align": "left"
	  },
	  "PunctumInclinatum": {
	    "svgSrc": "<path d=\"M0-75.78L50 0 0 75-50 0 0-75.78z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M0-75.78L50 0 0 75-50 0 0-75.78z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 150.77999877929688
	    },
	    "origin": {
	      "x": 50,
	      "y": 75.77999877929688
	    },
	    "align": "left"
	  },
	  "PunctumInclinatumLiquescent": {
	    "svgSrc": "<path d=\"M 0,-53.164062 35,-0.1171875 0,52.382812 -35,-0.1171875 0,-53.164062 z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M 0,-53.164062 35,-0.1171875 0,52.382812 -35,-0.1171875 0,-53.164062 z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 70,
	      "height": 105.546
	    },
	    "origin": {
	      "x": 35,
	      "y": 53.164062
	    },
	    "align": "left"
	  },
	  "Quilisma": {
	    "svgSrc": "<path d=\"M-50 34.938V-51c5.73 20.833 13.02 31.25 21.875 31.25 7.813 0 12.5-15.625 14.063-46.875 3.645 12.5 6.9 21.224 9.765 26.172s6.9 7.422 12.11 7.422c5.208 0 9.374-14.324 12.5-42.97 5.73 22.917 10.677 34.375 14.843 34.375 5.73 0 10.677-15.885 14.844-47.656v100c0 17.707-3.125 26.56-9.375 26.56-4.688 0-9.115-5.988-13.28-17.968-2.085 21.875-8.074 32.813-17.97 32.813-7.813 0-16.146-7.292-25-21.875-4.688 20.312-10.677 30.47-17.97 30.47-5.207 0-9.244-2.605-12.108-7.814C-48.568 47.698-50 41.708-50 34.938z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-50 34.938V-51c5.73 20.833 13.02 31.25 21.875 31.25 7.813 0 12.5-15.625 14.063-46.875 3.645 12.5 6.9 21.224 9.765 26.172s6.9 7.422 12.11 7.422c5.208 0 9.374-14.324 12.5-42.97 5.73 22.917 10.677 34.375 14.843 34.375 5.73 0 10.677-15.885 14.844-47.656v100c0 17.707-3.125 26.56-9.375 26.56-4.688 0-9.115-5.988-13.28-17.968-2.085 21.875-8.074 32.813-17.97 32.813-7.813 0-16.146-7.292-25-21.875-4.688 20.312-10.677 30.47-17.97 30.47-5.207 0-9.244-2.605-12.108-7.814C-48.568 47.698-50 41.708-50 34.938z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 150
	    },
	    "origin": {
	      "x": 50,
	      "y": 89.28199768066406
	    },
	    "align": "left"
	  },
	  "TerminatingAscLiquescent": {
	    "svgSrc": "<path d=\"M-9.375 40.22c0-11.98-4.948-17.97-14.844-17.97-10.936 0-19.53 3.646-25.78 10.938v-53.126c0-6.77 2.604-12.76 7.813-17.968 5.208-5.21 10.677-8.594 16.406-10.157 2.603-.52 5.207-.78 7.81-.78 3.647 0 7.032.78 10.157 2.343C-2.603-43.896 0-39.73 0-34V73.03h-9.375V40.22z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-9.375 40.22c0-11.98-4.948-17.97-14.844-17.97-10.936 0-19.53 3.646-25.78 10.938v-53.126c0-6.77 2.604-12.76 7.813-17.968 5.208-5.21 10.677-8.594 16.406-10.157 2.603-.52 5.207-.78 7.81-.78 3.647 0 7.032.78 10.157 2.343C-2.603-43.896 0-39.73 0-34V73.03h-9.375V40.22z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 49.999000549316406,
	      "height": 121.87299346923828
	    },
	    "origin": {
	      "x": 49.999000549316406,
	      "y": 48.842994689941406
	    },
	    "align": "right"
	  },
	  "TerminatingDesLiquescent": {
	    "svgSrc": "<path d=\"M-9.375-48.156V-80.97H0V26.845c0 5.73-2.604 9.896-7.813 12.5-3.125 1.562-6.51 2.343-10.156 2.343-2.603 0-5.207-.26-7.81-.78-5.73-1.563-11.2-4.95-16.407-10.157C-47.398 25.542-50 19.292-50 12v-52.344c6.25 7.292 14.844 10.938 25.78 10.938 9.897 0 14.845-6.25 14.845-18.75z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-9.375-48.156V-80.97H0V26.845c0 5.73-2.604 9.896-7.813 12.5-3.125 1.562-6.51 2.343-10.156 2.343-2.603 0-5.207-.26-7.81-.78-5.73-1.563-11.2-4.95-16.407-10.157C-47.398 25.542-50 19.292-50 12v-52.344c6.25 7.292 14.844 10.938 25.78 10.938 9.897 0 14.845-6.25 14.845-18.75z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 50,
	      "height": 122.65800476074219
	    },
	    "origin": {
	      "x": 50,
	      "y": 80.97000122070312
	    },
	    "align": "right"
	  },
	  "VerticalEpisemaAbove": {
	    "svgSrc": "<path d=\"M-8-80H8L4 0h-8l-4-80z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-8-80H8L4 0h-8l-4-80z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 16,
	      "height": 80
	    },
	    "origin": {
	      "x": 8,
	      "y": 80
	    },
	    "align": "left"
	  },
	  "VerticalEpisemaBelow": {
	    "svgSrc": "<path d=\"M-8 80H8L4 0h-8l-4 80z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M-8 80H8L4 0h-8l-4 80z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 16,
	      "height": 80
	    },
	    "origin": {
	      "x": 8,
	      "y": 0
	    },
	    "align": "left"
	  },
	  "VirgaLong": {
	    "svgSrc": "<path d=\"M50-38v285.156c0 6.77-2.344 10.937-7.03 12.5-1.564 0-2.605-.78-3.126-2.344-.52-1.562-.782-10.156-.782-25.78V54.186C29.168 45.334 16.146 40.907 0 40.907c-22.917 0-39.583 5.208-50 15.624V-38c0-19.27 16.667-28.906 50-28.906S50-57.27 50-38z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M50-38v285.156c0 6.77-2.344 10.937-7.03 12.5-1.564 0-2.605-.78-3.126-2.344-.52-1.562-.782-10.156-.782-25.78V54.186C29.168 45.334 16.146 40.907 0 40.907c-22.917 0-39.583 5.208-50 15.624V-38c0-19.27 16.667-28.906 50-28.906S50-57.27 50-38z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 326.56201171875
	    },
	    "origin": {
	      "x": 50,
	      "y": 66.90599822998047
	    },
	    "align": "left"
	  },
	  "VirgaShort": {
	    "svgSrc": "<path d=\"M50-38v211.72c0 7.29-2.344 11.457-7.03 12.5-1.564 0-2.606-.783-3.126-2.345-.52-1.563-.782-10.156-.782-25.78V54.187C29.167 45.332 16.146 40.906 0 40.906c-22.917 0-39.583 5.21-50 15.625V-38c0-19.27 16.667-28.906 50-28.906S50-57.27 50-38z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M50-38v211.72c0 7.29-2.344 11.457-7.03 12.5-1.564 0-2.606-.783-3.126-2.345-.52-1.563-.782-10.156-.782-25.78V54.187C29.167 45.332 16.146 40.906 0 40.906c-22.917 0-39.583 5.21-50 15.625V-38c0-19.27 16.667-28.906 50-28.906S50-57.27 50-38z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 100,
	      "height": 253.12600708007812
	    },
	    "origin": {
	      "x": 50,
	      "y": 66.90599822998047
	    },
	    "align": "left"
	  },
	  "Virgula": {
	    "svgSrc": "<path d=\"M8.178-55.66c0-22.137 12.092-33.2 36.287-33.2 11.835 0 23.53 5.66 35.108 16.98C91.15-60.547 96.94-41.766 96.94-15.534c0 53.515-31.646 87.487-94.937 101.895-2.048-2.06-3.077-5.146-3.077-9.273 0-1.03.247-1.8.76-2.316 42.71-19.027 64.075-41.678 64.075-67.92 0-11.322-2.325-20.326-6.945-27.016-4.62-6.69-9.52-11.052-14.676-13.11-5.147-2.048-11.836-3.85-20.07-5.403C12.81-39.707 8.18-45.37 8.18-55.66z\"/>",
	    "paths": [{
	      "type": "positive",
	      "data": "M8.178-55.66c0-22.137 12.092-33.2 36.287-33.2 11.835 0 23.53 5.66 35.108 16.98C91.15-60.547 96.94-41.766 96.94-15.534c0 53.515-31.646 87.487-94.937 101.895-2.048-2.06-3.077-5.146-3.077-9.273 0-1.03.247-1.8.76-2.316 42.71-19.027 64.075-41.678 64.075-67.92 0-11.322-2.325-20.326-6.945-27.016-4.62-6.69-9.52-11.052-14.676-13.11-5.147-2.048-11.836-3.85-20.07-5.403C12.81-39.707 8.18-45.37 8.18-55.66z"
	    }],
	    "bounds": {
	      "x": 0,
	      "y": 0,
	      "width": 98.01399993896484,
	      "height": 175.2209930419922
	    },
	    "origin": {
	      "x": 1.0739939212799072,
	      "y": 88.86000061035156
	    },
	    "align": "left"
	  }
	};

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.ChantNotationElement = exports.Annotation = exports.DropCap = exports.Lyric = exports.LyricType = exports.TextElement = exports.CurlyBraceVisualizer = exports.RoundBraceVisualizer = exports.GlyphVisualizer = exports.VirgaLineVisualizer = exports.NeumeLineVisualizer = exports.DividerLineVisualizer = exports.ChantLayoutElement = exports.ChantContext = exports.TextMeasuringStrategy = exports.QuickSvg = exports.GlyphCode = undefined;
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var _Exsurge = __webpack_require__(1);
	
	var _Exsurge2 = __webpack_require__(3);
	
	var _Exsurge3 = __webpack_require__(2);
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// load in the web font for special chant characters here:
	var __exsurgeCharactersFont = __webpack_require__(5);
	
	var GlyphCode = exports.GlyphCode = {
	
	  None: "None",
	
	  AcuteAccent: "AcuteAccent",
	  Stropha: "Stropha",
	  StrophaLiquescent: "StrophaLiquescent",
	
	  BeginningAscLiquescent: "BeginningAscLiquescent",
	  BeginningDesLiquescent: "BeginningDesLiquescent",
	
	  CustosDescLong: "CustosDescLong",
	  CustosDescShort: "CustosDescShort",
	  CustosLong: "CustosLong",
	  CustosShort: "CustosShort",
	
	  // clefs and other markings
	  DoClef: "DoClef",
	  FaClef: "FaClef",
	  Flat: "Flat",
	  Mora: "Mora",
	  Natural: "Natural",
	  OriscusAsc: "OriscusAsc",
	  OriscusDes: "OriscusDes",
	  OriscusLiquescent: "OriscusLiquescent",
	
	  PodatusLower: "PodatusLower",
	  PodatusUpper: "PodatusUpper",
	
	  Porrectus1: "Porrectus1", // 1 staff line difference,
	  Porrectus2: "Porrectus2", // 2 lines difference, etc...
	  Porrectus3: "Porrectus3",
	  Porrectus4: "Porrectus4",
	
	  PunctumCavum: "PunctumCavum",
	  PunctumQuadratum: "PunctumQuadratum",
	  PunctumQuadratumAscLiquescent: "PunctumQuadratumAscLiquescent",
	  PunctumQuadratumDesLiquescent: "PunctumQuadratumDesLiquescent",
	  PunctumInclinatum: "PunctumInclinatum",
	  PunctumInclinatumLiquescent: "PunctumInclinatumLiquescent",
	  Quilisma: "Quilisma",
	
	  TerminatingAscLiquescent: "TerminatingAscLiquescent",
	  TerminatingDesLiquescent: "TerminatingDesLiquescent",
	  VerticalEpisemaAbove: "VerticalEpisemaAbove",
	  VerticalEpisemaBelow: "VerticalEpisemaBelow",
	  VirgaLong: "VirgaLong",
	  VirgaShort: "VirgaShort",
	  Virgula: "Virgula",
	
	  UpperBrace: "UpperBrace"
	}; // GlyphCode
	
	var QuickSvg = exports.QuickSvg = {
	
	  // namespaces 
	  ns: 'http://www.w3.org/2000/svg',
	  xmlns: 'http://www.w3.org/2000/xmlns/',
	  xlink: 'http://www.w3.org/1999/xlink',
	
	  // create the root level svg object
	  svg: function svg(width, height) {
	    var node = document.createElementNS(this.ns, 'svg');
	
	    node.setAttribute('xmlns', this.ns);
	    node.setAttribute('version', '1.1');
	    node.setAttributeNS(this.xmlns, 'xmlns:xlink', this.xlink);
	
	    node.setAttribute('width', width);
	    node.setAttribute('height', height);
	
	    // create the defs element
	    var defs = document.createElementNS(this.ns, 'defs');
	    node.appendChild(defs);
	
	    node.defs = defs;
	
	    node.clearNotations = function () {
	      // clear out all children except defs
	      node.removeChild(defs);
	
	      while (node.hasChildNodes()) {
	        node.removeChild(node.lastChild);
	      }node.appendChild(defs);
	    };
	
	    return node;
	  },
	
	  rect: function rect(width, height) {
	    var node = document.createElementNS(this.ns, 'rect');
	
	    node.setAttribute('width', width);
	    node.setAttribute('height', height);
	
	    return node;
	  },
	
	  line: function line(x1, y1, x2, y2) {
	    var node = document.createElementNS(this.ns, 'line');
	
	    node.setAttribute('x1', x1);
	    node.setAttribute('y1', y1);
	    node.setAttribute('x2', x2);
	    node.setAttribute('y2', y2);
	
	    return node;
	  },
	
	  g: function g() {
	    var node = document.createElementNS(this.ns, 'g');
	
	    return node;
	  },
	
	  text: function text() {
	    var node = document.createElementNS(this.ns, 'text');
	
	    return node;
	  },
	
	  tspan: function tspan(str) {
	    var node = document.createElementNS(this.ns, 'tspan');
	    node.textContent = str;
	
	    return node;
	  },
	
	  // nodeRef should be the id of the object in defs (without the #)
	  use: function use(nodeRef) {
	    var node = document.createElementNS(this.ns, 'use');
	    node.setAttributeNS(this.xlink, "xlink:href", '#' + nodeRef);
	
	    return node;
	  },
	
	  createFragment: function createFragment(name, attributes, child) {
	    if (child === undefined || child === null) child = '';
	
	    var fragment = '<' + name + ' ';
	
	    for (var attr in attributes) {
	      if (attributes.hasOwnProperty(attr)) fragment += attr + '="' + attributes[attr] + '" ';
	    }
	
	    fragment += '>' + child + '</' + name + '>';
	
	    return fragment;
	  },
	
	  parseFragment: function parseFragment(fragment) {
	
	    // create temporary holder
	    var well = document.createElement('svg');
	
	    // act as a setter if svg is given
	    if (fragment) {
	
	      var container = this.g();
	
	      // dump raw svg
	      // do this to allow the browser to automatically create svg nodes?
	      well.innerHTML = '<svg>' + fragment.replace(/\n/, '').replace(/<(\w+)([^<]+?)\/>/g, '<$1$2></$1>') + '</svg>';
	
	      // transplant nodes
	      for (var i = 0, il = well.firstChild.childNodes.length; i < il; i++) {
	        container.appendChild(well.firstChild.firstChild);
	      }return container;
	    }
	  },
	
	  translate: function translate(node, x, y) {
	    node.setAttribute('transform', 'translate(' + x + ',' + y + ')');
	    return node;
	  },
	
	  scale: function scale(node, sx, sy) {
	    node.setAttribute('transform', 'scale(' + sx + ',' + sy + ')');
	    return node;
	  }
	};
	
	var TextMeasuringStrategy = exports.TextMeasuringStrategy = {
	  // shapes
	  Svg: 0,
	  Canvas: 1
	};
	
	/*
	 * ChantContext
	 */
	
	var ChantContext = exports.ChantContext = function () {
	  function ChantContext() {
	    var textMeasuringStrategy = arguments.length <= 0 || arguments[0] === undefined ? TextMeasuringStrategy.Svg : arguments[0];
	
	    _classCallCheck(this, ChantContext);
	
	    this.textMeasuringStrategy = textMeasuringStrategy;
	    this.defs = {};
	
	    // font styles
	    this.lyricTextSize = 16; // in points?
	    this.lyricTextFont = "'Palatino Linotype', 'Book Antiqua', Palatino, serif";
	    this.lyricTextColor = "#000";
	
	    this.dropCapTextSize = 64;
	    this.dropCapTextFont = this.lyricTextFont;
	    this.dropCapTextColor = this.lyricTextColor;
	
	    this.annotationTextSize = 13;
	    this.annotationTextFont = this.lyricTextFont;
	    this.annotationTextColor = this.lyricTextColor;
	
	    // everything depends on the scale of the punctum
	    this.glyphPunctumWidth = _Exsurge2.Glyphs.PunctumQuadratum.bounds.width;
	    this.glyphPunctumHeight = _Exsurge2.Glyphs.PunctumQuadratum.bounds.height;
	
	    // fixme: for now, we just set these using the glyph scales as noted above, presuming a
	    // staff line size of 0.5 in. Really what we should do is scale the punctum size based
	    // on the text metrics, right? 1 punctum ~ x height size?
	    this.glyphScaling = 1.0 / 16.0;
	
	    this.staffInterval = this.glyphPunctumWidth * this.glyphScaling;
	
	    // setup the line weights for the various elements.
	    // we
	    this.staffLineWeight = Math.round(this.glyphPunctumWidth * this.glyphScaling / 8);
	    this.neumeLineWeight = this.staffLineWeight; // the weight of connecting lines in the glyphs.
	    this.dividerLineWeight = this.neumeLineWeight; // of quarter bar, half bar, etc.
	    this.episemaLineWeight = this.neumeLineWeight; // of horizontal episemae
	
	    // for keeping track of the clef
	    this.activeClef = null;
	
	    this.neumeLineColor = "#000";
	    this.staffLineColor = "#000";
	    this.dividerLineColor = "#000";
	
	    this.defaultLanguage = new _Exsurge3.Latin();
	
	    this.canvas = document.createElement("canvas");
	    this.canvasCtxt = this.canvas.getContext("2d");
	
	    // calculate the pixel ratio for drawing to a canvas
	    var dpr = window.devicePixelRatio || 1.0;
	    var bsr = this.canvasCtxt.webkitBackingStorePixelRatio || this.canvasCtxt.mozBackingStorePixelRatio || this.canvasCtxt.msBackingStorePixelRatio || this.canvasCtxt.oBackingStorePixelRatio || this.canvasCtxt.backingStorePixelRatio || 1.0;
	
	    this.pixelRatio = dpr / bsr;
	
	    this.canvasCtxt.setTransform(this.pixelRatio, 0, 0, this.pixelRatio, 0, 0);
	
	    if (textMeasuringStrategy === TextMeasuringStrategy.Svg) {
	      this.svgTextMeasurer = QuickSvg.svg(1, 1);
	      this.svgTextMeasurer.setAttribute('id', "TextMeasurer");
	      document.querySelector('body').appendChild(this.svgTextMeasurer);
	    }
	
	    // measure the size of a hyphen for the lyrics
	    var hyphen = new Lyric(this, "-", LyricType.SingleSyllable);
	    this.hyphenWidth = hyphen.bounds.width;
	
	    this.minLyricWordSpacing = this.hyphenWidth;
	
	    this.intraNeumeSpacing = this.staffInterval / 2.0;
	
	    // for connecting neume syllables...
	    this.syllableConnector = '-';
	
	    this.drawGuides = false;
	    this.drawDebuggingBounds = true;
	
	    // we keep track of where we are in processing notations, so that
	    // we can maintain the context for notations to know about.
	    //
	    // these are only gauranteed to be valid during the performLayout phase!
	    this.activeNotations = null;
	    this.currNotationIndex = -1;
	
	    // chant notation elements are normally separated by a minimum fixed amount of space
	    // on the staff line. It can happen, however, that two text elements are almost close
	    // enough to merge, only to be separated much more by the required hyphen (or other
	    // connecting string).
	    //
	    // This tolerance value allows a little bit of flexibility to merge two close lyrical
	    // elements, thus bringing the chant notation elements a bit closer than otherwise
	    // would be normally allowed.
	    //
	    // condensing tolerance is a percentage value (0.0-1.0, inclusive) that indicates
	    // how much the default spacing can shrink. E.g., a value of 0.80 allows the layout
	    // engine to separate two glyphs by only 80% of the normal inter-neume spacing value.
	    //
	    // fixme: condensing tolerance is not implemented yet!
	    this.condensingTolerance = 0.9;
	
	    // if auto color is true, then exsurge tries to automatically colorize
	    // some elements of the chant (directives become rubric color, etc.)
	    this.autoColor = true;
	
	    this.insertFontsInDoc();
	  }
	
	  _createClass(ChantContext, [{
	    key: 'calculateHeightFromStaffPosition',
	    value: function calculateHeightFromStaffPosition(staffPosition) {
	      return -staffPosition * this.staffInterval;
	    }
	  }, {
	    key: 'insertFontsInDoc',
	    value: function insertFontsInDoc() {
	
	      var styleElement = document.getElementById('exsurge-fonts');
	
	      if (styleElement === null) {
	        // create it since it doesn't exist yet.
	        styleElement = document.createElement('style');
	        styleElement.id = 'exsurge-fonts';
	
	        styleElement.appendChild(document.createTextNode("@font-face{font-family: 'Exsurge Characters';font-weight: normal;font-style: normal;src: url(" + __exsurgeCharactersFont + ") format('opentype');}"));
	
	        document.head.appendChild(styleElement);
	      }
	    }
	
	    // returns the next neume starting at this.currNotationIndex, or null
	    // if there isn't a neume after this one...
	
	  }, {
	    key: 'findNextNeume',
	    value: function findNextNeume() {
	
	      if (typeof this.currNotationIndex === 'undefined') throw "findNextNeume() called without a valid currNotationIndex set";
	
	      for (var i = this.currNotationIndex + 1; i < this.notations.length; i++) {
	        var notation = this.notations[i];
	
	        if (notation.isNeume) return notation;
	      }
	
	      return null;
	    }
	  }, {
	    key: 'setCanvasSize',
	    value: function setCanvasSize(width, height) {
	      this.canvas.width = width * this.pixelRatio;
	      this.canvas.height = height * this.pixelRatio;
	      this.canvas.style.width = width + "px";
	      this.canvas.style.height = height + "px";
	
	      this.canvasCtxt.setTransform(this.pixelRatio, 0, 0, this.pixelRatio, 0, 0);
	    }
	  }]);
	
	  return ChantContext;
	}();
	
	/*
	 * ChantLayoutElement
	 */
	
	
	var ChantLayoutElement = exports.ChantLayoutElement = function () {
	  function ChantLayoutElement() {
	    _classCallCheck(this, ChantLayoutElement);
	
	    this.bounds = new _Exsurge.Rect();
	    this.origin = new _Exsurge.Point(0, 0);
	
	    this.selected = false;
	    this.highlighted = false;
	  }
	
	  // draws the element on an html5 canvas
	
	
	  _createClass(ChantLayoutElement, [{
	    key: 'draw',
	    value: function draw(ctxt) {}
	
	    // returns svg code for the element, used for printing support
	
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      throw "ChantLayout Elements must implement createSvgFragment(ctxt)";
	    }
	  }]);
	
	  return ChantLayoutElement;
	}();
	
	var DividerLineVisualizer = exports.DividerLineVisualizer = function (_ChantLayoutElement) {
	  _inherits(DividerLineVisualizer, _ChantLayoutElement);
	
	  function DividerLineVisualizer(ctxt, staffPosition0, staffPosition1) {
	    _classCallCheck(this, DividerLineVisualizer);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(DividerLineVisualizer).call(this));
	
	    var y0 = ctxt.calculateHeightFromStaffPosition(staffPosition0);
	    var y1 = ctxt.calculateHeightFromStaffPosition(staffPosition1);
	
	    if (y0 > y1) {
	      var temp = y0;
	      y0 = y1;
	      y1 = temp;
	    }
	
	    _this.bounds.x = 0;
	    _this.bounds.y = y0;
	    _this.bounds.width = ctxt.dividerLineWeight;
	    _this.bounds.height = y1 - y0;
	
	    _this.origin.x = _this.bounds.width / 2;
	    _this.origin.y = y0;
	    return _this;
	  }
	
	  _createClass(DividerLineVisualizer, [{
	    key: 'draw',
	    value: function draw(ctxt) {
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      canvasCtxt.lineWidth = this.bounds.width;
	      canvasCtxt.strokeStyle = ctxt.dividerLineColor;
	
	      canvasCtxt.beginPath();
	      canvasCtxt.moveTo(this.bounds.x - this.origin.x, this.bounds.y);
	      canvasCtxt.lineTo(this.bounds.x - this.origin.x, this.bounds.y + this.bounds.height);
	      canvasCtxt.stroke();
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      return QuickSvg.createFragment('rect', {
	        'x': this.bounds.x,
	        'y': this.bounds.y,
	        'width': ctxt.dividerLineWeight,
	        'height': this.bounds.height,
	        'fill': ctxt.dividerLineColor,
	        'class': 'dividerLine'
	      });
	    }
	  }]);
	
	  return DividerLineVisualizer;
	}(ChantLayoutElement);
	
	var NeumeLineVisualizer = exports.NeumeLineVisualizer = function (_ChantLayoutElement2) {
	  _inherits(NeumeLineVisualizer, _ChantLayoutElement2);
	
	  function NeumeLineVisualizer(ctxt, note0, note1, hanging) {
	    _classCallCheck(this, NeumeLineVisualizer);
	
	    var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(NeumeLineVisualizer).call(this));
	
	    var staffPosition0 = note0.staffPosition;
	    var staffPosition1 = note1.staffPosition;
	
	    // note0 should be the upper one for our calculations here
	    if (staffPosition0 < staffPosition1) {
	      var temp = staffPosition0;
	      staffPosition0 = staffPosition1;
	      staffPosition1 = temp;
	    }
	
	    var y0 = ctxt.calculateHeightFromStaffPosition(staffPosition0);
	    var y1 = 0;
	
	    if (hanging) {
	
	      // if the difference between the notes is only one, and the upper
	      // note is on a line, and the lower note is within the four staff lines,
	      // then our hanging line goes past the lower note by a whole
	      // staff interval
	      if (staffPosition0 - staffPosition1 === 1 && Math.abs(staffPosition0) % 2 === 1 && staffPosition1 > -3) staffPosition1--;
	
	      y1 += ctxt.glyphPunctumHeight * ctxt.glyphScaling / 2.2;
	    }
	
	    y1 += ctxt.calculateHeightFromStaffPosition(staffPosition1);
	
	    _this2.bounds.x = 0;
	    _this2.bounds.y = y0;
	    _this2.bounds.width = ctxt.neumeLineWeight;
	    _this2.bounds.height = y1 - y0;
	
	    _this2.origin.x = 0;
	    _this2.origin.y = 0;
	    return _this2;
	  }
	
	  _createClass(NeumeLineVisualizer, [{
	    key: 'draw',
	    value: function draw(ctxt) {
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      canvasCtxt.lineWidth = this.bounds.width;
	      canvasCtxt.strokeStyle = ctxt.neumeLineColor;
	
	      canvasCtxt.beginPath();
	
	      // since the canvas context draws strokes centered on the path
	      // and neume lines are supposed to be draw left aligned,
	      // we need to offset the line by half the line width.
	      var x = this.bounds.x + this.bounds.width / 2;
	
	      canvasCtxt.moveTo(x, this.bounds.y);
	      canvasCtxt.lineTo(x, this.bounds.y + this.bounds.height);
	      canvasCtxt.stroke();
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      return QuickSvg.createFragment('rect', {
	        'x': this.bounds.x,
	        'y': this.bounds.y,
	        'width': ctxt.neumeLineWeight,
	        'height': this.bounds.height,
	        'fill': ctxt.neumeLineColor,
	        'class': 'neumeLine'
	      });
	    }
	  }]);
	
	  return NeumeLineVisualizer;
	}(ChantLayoutElement);
	
	var VirgaLineVisualizer = exports.VirgaLineVisualizer = function (_ChantLayoutElement3) {
	  _inherits(VirgaLineVisualizer, _ChantLayoutElement3);
	
	  function VirgaLineVisualizer(ctxt, note) {
	    _classCallCheck(this, VirgaLineVisualizer);
	
	    var _this3 = _possibleConstructorReturn(this, Object.getPrototypeOf(VirgaLineVisualizer).call(this));
	
	    var staffPosition = note.staffPosition;
	
	    var y0 = ctxt.calculateHeightFromStaffPosition(staffPosition);
	    var y1;
	
	    if (Math.abs(staffPosition % 2) === 0) y1 = y0 + ctxt.staffInterval * 1.8;else y1 = y0 + ctxt.staffInterval * 2.7;
	
	    _this3.bounds.x = 0;
	    _this3.bounds.y = y0;
	    _this3.bounds.width = ctxt.neumeLineWeight;
	    _this3.bounds.height = y1 - y0;
	
	    _this3.origin.x = 0;
	    _this3.origin.y = 0;
	    return _this3;
	  }
	
	  _createClass(VirgaLineVisualizer, [{
	    key: 'draw',
	    value: function draw(ctxt) {
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      canvasCtxt.lineWidth = this.bounds.width;
	      canvasCtxt.strokeStyle = ctxt.neumeLineColor;
	
	      canvasCtxt.beginPath();
	      canvasCtxt.moveTo(this.bounds.x, this.bounds.y);
	      canvasCtxt.lineTo(this.bounds.x, this.bounds.y + this.bounds.height);
	      canvasCtxt.stroke();
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      return QuickSvg.createFragment('rect', {
	        'x': this.bounds.x,
	        'y': this.bounds.y,
	        'width': ctxt.neumeLineWeight,
	        'height': this.bounds.height,
	        'fill': ctxt.neumeLineColor,
	        'class': 'neumeLine'
	      });
	    }
	  }]);
	
	  return VirgaLineVisualizer;
	}(ChantLayoutElement);
	
	var GlyphVisualizer = exports.GlyphVisualizer = function (_ChantLayoutElement4) {
	  _inherits(GlyphVisualizer, _ChantLayoutElement4);
	
	  function GlyphVisualizer(ctxt, glyphCode) {
	    _classCallCheck(this, GlyphVisualizer);
	
	    var _this4 = _possibleConstructorReturn(this, Object.getPrototypeOf(GlyphVisualizer).call(this));
	
	    _this4.glyph = null;
	
	    _this4.setGlyph(ctxt, glyphCode);
	    return _this4;
	  }
	
	  _createClass(GlyphVisualizer, [{
	    key: 'setGlyph',
	    value: function setGlyph(ctxt, glyphCode) {
	
	      if (this.glyphCode === glyphCode) return;
	
	      if (typeof glyphCode === 'undefined' || glyphCode === null || glyphCode === "") this.glyphCode = GlyphCode.None;else this.glyphCode = glyphCode;
	
	      this.glyph = _Exsurge2.Glyphs[this.glyphCode];
	
	      // if this glyph hasn't been used yet, then load it up in the defs section for sharing
	      if (!ctxt.defs.hasOwnProperty(this.glyphCode)) {
	        var glyphSrc = this.glyph.svgSrc;
	
	        // create the ref
	        ctxt.defs[this.glyphCode] = QuickSvg.createFragment('g', {
	          id: this.glyphCode,
	          'class': 'glyph',
	          transform: 'scale(' + ctxt.glyphScaling + ')'
	        }, glyphSrc);
	      }
	
	      this.align = this.glyph.align;
	
	      this.origin.x = this.glyph.origin.x * ctxt.glyphScaling;
	      this.origin.y = this.glyph.origin.y * ctxt.glyphScaling;
	
	      this.bounds.x = 0;
	      this.bounds.y = -this.origin.y;
	      this.bounds.width = this.glyph.bounds.width * ctxt.glyphScaling;
	      this.bounds.height = this.glyph.bounds.height * ctxt.glyphScaling;
	    }
	  }, {
	    key: 'setStaffPosition',
	    value: function setStaffPosition(ctxt, staffPosition) {
	      this.bounds.y += ctxt.calculateHeightFromStaffPosition(staffPosition);
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      var x = this.bounds.x + this.origin.x;
	      var y = this.bounds.y + this.origin.y;
	      canvasCtxt.translate(x, y);
	      canvasCtxt.scale(ctxt.glyphScaling, ctxt.glyphScaling);
	
	      for (var i = 0; i < this.glyph.paths.length; i++) {
	        var path = this.glyph.paths[i];
	        canvasCtxt.fillStyle = ctxt.neumeLineColor;
	        canvasCtxt.fill(new Path2D(path.data));
	      }
	
	      canvasCtxt.scale(1.0 / ctxt.glyphScaling, 1.0 / ctxt.glyphScaling);
	      canvasCtxt.translate(-x, -y);
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      return QuickSvg.createFragment('use', {
	        'xlink:href': '#' + this.glyphCode,
	        x: this.bounds.x + this.origin.x,
	        y: this.bounds.y + this.origin.y
	      });
	    }
	  }]);
	
	  return GlyphVisualizer;
	}(ChantLayoutElement);
	
	var RoundBraceVisualizer = exports.RoundBraceVisualizer = function (_ChantLayoutElement5) {
	  _inherits(RoundBraceVisualizer, _ChantLayoutElement5);
	
	  function RoundBraceVisualizer(ctxt, x1, x2, y, isAbove) {
	    _classCallCheck(this, RoundBraceVisualizer);
	
	    var _this5 = _possibleConstructorReturn(this, Object.getPrototypeOf(RoundBraceVisualizer).call(this));
	
	    if (x1 > x2) {
	      // swap the xs
	      var temp = x1;
	      x1 = x2;
	      x2 = temp;
	    }
	
	    _this5.isAbove = isAbove;
	    _this5.braceHeight = ctxt.staffInterval / 2;
	
	    _this5.bounds = new _Exsurge.Rect(x1, y, x2 - x1, _this5.braceHeight);
	
	    _this5.origin.x = 0;
	    _this5.origin.y = 0;
	    return _this5;
	  }
	
	  _createClass(RoundBraceVisualizer, [{
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      var fragment = QuickSvg.createFragment('path', {
	        'd': this.generatePathString(),
	        'stroke': ctxt.neumeLineColor,
	        'stroke-width': ctxt.staffLineWeight + 'px',
	        'fill': 'none',
	        'class': 'brace'
	      });
	
	      if (this.acuteAccent) {
	
	        fragment += this.acuteAccent.createSvgFragment(ctxt);
	
	        return QuickSvg.createFragment('g', {
	          'class': 'accentedBrace'
	        }, fragment);
	      } else return fragment;
	    }
	
	    // returns svg path d string
	
	  }, {
	    key: 'generatePathString',
	    value: function generatePathString() {
	
	      var x1 = this.bounds.x;
	      var x2 = this.bounds.right();
	      var width = this.bounds.width;
	      var y, dx, dy;
	
	      if (this.isAbove) {
	        y = this.bounds.bottom();
	        dx = width / 6;
	        dy = -width / 6;
	      } else {
	        y = this.bounds.y;
	        dx = width / 6;
	        dy = width / 6;
	      }
	
	      //Calculate Control Points of path,
	      var cx1 = x1 + dx;
	      var cy = y + dy;
	      var cx2 = x2 - dx;
	
	      // two decimal points should be enough, but if we need more precision, we can
	      // up it here.
	      var dp = 2;
	      return "M " + x1.toFixed(dp) + " " + y.toFixed(dp) + " C " + cx1.toFixed(dp) + " " + cy.toFixed(dp) + " " + cx2.toFixed(dp) + " " + cy.toFixed(dp) + " " + x2.toFixed(dp) + " " + y.toFixed(dp);
	    }
	  }]);
	
	  return RoundBraceVisualizer;
	}(ChantLayoutElement);
	
	var CurlyBraceVisualizer = exports.CurlyBraceVisualizer = function (_ChantLayoutElement6) {
	  _inherits(CurlyBraceVisualizer, _ChantLayoutElement6);
	
	  function CurlyBraceVisualizer(ctxt, x1, x2, y) {
	    var isAbove = arguments.length <= 4 || arguments[4] === undefined ? true : arguments[4];
	    var addAcuteAccent = arguments.length <= 5 || arguments[5] === undefined ? false : arguments[5];
	
	    _classCallCheck(this, CurlyBraceVisualizer);
	
	    var _this6 = _possibleConstructorReturn(this, Object.getPrototypeOf(CurlyBraceVisualizer).call(this));
	
	    if (x1 > x2) {
	      // swap the xs
	      var temp = x1;
	      x1 = x2;
	      x2 = temp;
	    }
	
	    _this6.isAbove = isAbove;
	    _this6.braceHeight = ctxt.staffInterval / 2;
	
	    // y is the actual vertical start of the brace (left hand side)
	    // thus for a brace over notes, bounds.y is the bottom of brace,
	    // but for a brace under the notes, y is simply the y passed in.
	    if (isAbove) y -= _this6.braceHeight;
	
	    var bounds = new _Exsurge.Rect(x1, y, x2 - x1, _this6.braceHeight);
	
	    if (addAcuteAccent && isAbove) {
	
	      _this6.acuteAccent = new GlyphVisualizer(ctxt, GlyphCode.AcuteAccent);
	      _this6.acuteAccent.bounds.x += bounds.x + (x2 - x1) / 2;
	      _this6.acuteAccent.bounds.y += bounds.y - ctxt.staffInterval / 4;
	
	      bounds.union(_this6.acuteAccent.bounds);
	    }
	
	    _this6.bounds = bounds;
	
	    _this6.origin.x = 0;
	    _this6.origin.y = 0;
	    return _this6;
	  }
	
	  _createClass(CurlyBraceVisualizer, [{
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      var fragment = QuickSvg.createFragment('path', {
	        'd': this.generatePathString(),
	        'stroke': ctxt.neumeLineColor,
	        'stroke-width': ctxt.staffLineWeight + 'px',
	        'fill': 'none',
	        'class': 'brace'
	      });
	
	      if (this.acuteAccent) {
	
	        fragment += this.acuteAccent.createSvgFragment(ctxt);
	
	        return QuickSvg.createFragment('g', {
	          'class': 'accentedBrace'
	        }, fragment);
	      } else return fragment;
	    }
	
	    // code below inspired by: https://gist.github.com/alexhornbake
	    // optimized for braces that are only drawn horizontally.
	    // returns svg path d string
	
	  }, {
	    key: 'generatePathString',
	    value: function generatePathString() {
	
	      var q = 0.6; // .5 is normal, higher q = more expressive bracket
	
	      var x1 = this.bounds.x;
	      var x2 = this.bounds.right();
	      var width = this.bounds.width;
	      var y, h;
	
	      if (this.isAbove) {
	        y = this.bounds.bottom();
	        h = -this.braceHeight;
	      } else {
	        y = this.bounds.y;
	        h = this.braceHeight;
	      }
	
	      // calculate Control Points of path
	      var qy1 = y + q * h;
	      var qx2 = x1 + .25 * width;
	      var qy2 = y + (1 - q) * h;
	      var tx1 = x1 + .5 * width;
	      var ty1 = y + h;
	      var qy3 = y + q * h;
	      var qx4 = x1 + .75 * width;
	      var qy4 = y + (1 - q) * h;
	
	      // two decimal points should be enough, but if we need more precision, we can
	      // up it here.
	      var dp = 2;
	      return "M " + x1.toFixed(dp) + " " + y.toFixed(dp) + " Q " + x1.toFixed(dp) + " " + qy1.toFixed(dp) + " " + qx2.toFixed(dp) + " " + qy2.toFixed(dp) + " T " + tx1.toFixed(dp) + " " + ty1.toFixed(dp) + " M " + x2.toFixed(dp) + " " + y.toFixed(dp) + " Q " + x2.toFixed(dp) + " " + qy3.toFixed(dp) + " " + qx4.toFixed(dp) + " " + qy4.toFixed(dp) + " T " + tx1.toFixed(dp) + " " + ty1.toFixed(dp);
	    }
	  }]);
	
	  return CurlyBraceVisualizer;
	}(ChantLayoutElement);
	
	var TextSpan = function TextSpan(text, properties) {
	  if (typeof properties === 'undefined' || properties === null) properties = "";
	
	  this.text = text;
	  this.properties = properties;
	};
	
	var boldMarkup = "*";
	var italicMarkup = "_";
	var redMarkup = "^";
	var smallCapsMarkup = "%";
	
	function MarkupStackFrame(symbol, startIndex, properties) {
	  this.symbol = symbol;
	  this.startIndex = startIndex;
	  this.properties = properties;
	}
	
	MarkupStackFrame.createStackFrame = function (symbol, startIndex) {
	
	  var properties = "";
	
	  switch (symbol) {
	    case boldMarkup:
	      properties = 'font-weight:bold;';
	      break;
	    case italicMarkup:
	      properties = 'font-style:italic;';
	      break;
	    case redMarkup:
	      properties = 'fill:#f00;'; // SVG text color is set by the fill property
	      break;
	    case smallCapsMarkup:
	      properties = "font-variant:small-caps;font-feature-settings:'smcp';-webkit-font-feature-settings:'smcp';";
	      break;
	  }
	
	  return new MarkupStackFrame(symbol, startIndex, properties);
	};
	
	// for escaping html strings before they go into the svgs
	// adapted from http://stackoverflow.com/a/12034334/5720160
	var __subsForTspans = {
	  "&": "&amp;",
	  "<": "&lt;",
	  ">": "&gt;"
	};
	
	var TextElement = exports.TextElement = function (_ChantLayoutElement7) {
	  _inherits(TextElement, _ChantLayoutElement7);
	
	  function TextElement(ctxt, text, fontFamily, fontSize, textAnchor) {
	    _classCallCheck(this, TextElement);
	
	    // set these to some sane values for now...
	
	    var _this7 = _possibleConstructorReturn(this, Object.getPrototypeOf(TextElement).call(this));
	
	    _this7.bounds.x = 0;
	    _this7.bounds.y = 0;
	    _this7.bounds.width = 0;
	    _this7.bounds.height = 0;
	    _this7.origin.x = 0;
	    _this7.origin.y = 0;
	
	    _this7.fontFamily = fontFamily;
	    _this7.fontSize = fontSize;
	    _this7.textAnchor = textAnchor;
	    _this7.dominantBaseline = 'baseline'; // default placement
	
	    _this7.generateSpansFromText(ctxt, text);
	
	    _this7.recalculateMetrics(ctxt);
	    return _this7;
	  }
	
	  _createClass(TextElement, [{
	    key: 'generateSpansFromText',
	    value: function generateSpansFromText(ctxt, text) {
	
	      this.text = "";
	      this.spans = [];
	
	      // save ourselves a lot of grief for a very common text:
	      if (text === "*" || text === "†") {
	        this.spans.push(new TextSpan(text));
	        return;
	      }
	
	      var markupStack = [];
	      var spanStartIndex = 0;
	
	      var filterFrames = function filterFrames(frame, symbol) {
	        return frame.Symbol === symbol;
	      };
	
	      var that = this;
	      var closeSpan = function closeSpan(spanText, extraProperties) {
	        if (spanText === "") return;
	
	        that.text += spanText;
	
	        var properties = "";
	        for (var i = 0; i < markupStack.length; i++) {
	          properties += markupStack[i].properties;
	        }if (extraProperties) properties = properties + extraProperties;
	
	        that.spans.push(new TextSpan(spanText, properties));
	      };
	
	      var markupRegex = /(\*|_|\^|%|[ARVarv]\/\.)/g;
	
	      var match = null;
	      while (match = markupRegex.exec(text)) {
	
	        var markupSymbol = match[0];
	
	        // non-matching symbols first
	        if (markupSymbol === "A/." || markupSymbol === "R/." || markupSymbol === "V/." || markupSymbol === "a/." || markupSymbol === "r/." || markupSymbol === "v/.") {
	          closeSpan(text[match.index] + ".", "font-family:'Exsurge Characters';fill:#f00;");
	        } else if (markupStack.length === 0) {
	          // otherwise we're dealing with matching markup delimeters
	          // if this is our first markup frame, then just create an inline for preceding text and push the stack frame
	          closeSpan(text.substring(spanStartIndex, match.index));
	          markupStack.push(MarkupStackFrame.createStackFrame(markupSymbol, match.index));
	        } else {
	
	          if (markupStack[markupStack.length - 1].symbol === markupSymbol) {
	            // group close
	            closeSpan(text.substring(spanStartIndex, match.index));
	            markupStack.pop();
	          } else if (markupStack.filter(filterFrames).length > 0) {
	            // trying to open a recursive group (or forgot to close a previous group)
	            // in either case, we just unwind to the previous stack frame
	            spanStartIndex = markupStack[markupStack.length - 1].startIndex;
	            markupStack.pop();
	            continue;
	          } else {
	            // group open
	            closeSpan(text.substring(spanStartIndex, match.index));
	            markupStack.push(MarkupStackFrame.createStackFrame(markupSymbol, match.index));
	          }
	        }
	
	        // advance the start index past the current markup
	        spanStartIndex = match.index + markupSymbol.length;
	      }
	
	      // if we finished matches, and there is still some text left, create one final run
	      if (spanStartIndex < text.length) closeSpan(text.substring(spanStartIndex, text.length));
	
	      // if after all of that we still didn't create any runs, then just add the entire text
	      // string itself as a run
	      if (this.spans.length === 0) closeSpan(text);
	    }
	  }, {
	    key: 'measureSubstring',
	    value: function measureSubstring(ctxt, length) {
	      if (length === 0) return 0;
	      if (!length) length = Infinity;
	      var canvasCtxt = ctxt.canvasCtxt;
	      var baseFont = this.fontSize + "px " + this.fontFamily;
	      var width = 0;
	      var subStringLength = 0;
	      for (var i = 0; i < this.spans.length; i++) {
	        var font = '',
	            span = this.spans[i],
	            myText = span.text.slice(0, length - subStringLength);
	        if (span.properties.indexOf('font-style:italic;') >= 0) font += 'italic ';
	        if (span.properties.indexOf("font-variant:small-caps;") >= 0) font += 'small-caps ';
	        if (span.properties.indexOf('font-weight:bold;') >= 0) font += 'bold ';
	        font += baseFont;
	        canvasCtxt.font = font;
	        var metrics = canvasCtxt.measureText(myText, this.bounds.x, this.bounds.y);
	        width += metrics.width;
	        subStringLength += myText.length;
	        if (subStringLength === length) break;
	      }
	      return width;
	    }
	  }, {
	    key: 'recalculateMetrics',
	    value: function recalculateMetrics(ctxt) {
	
	      this.bounds.x = 0;
	      this.bounds.y = 0;
	
	      this.bounds.x = 0;
	      this.bounds.y = 0;
	
	      this.origin.x = 0;
	
	      if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Svg) {
	        var xml = '<svg xmlns="http://www.w3.org/2000/svg">' + this.createSvgFragment(ctxt) + '</svg>';
	        var doc = new DOMParser().parseFromString(xml, 'application/xml');
	
	        while (ctxt.svgTextMeasurer.firstChild) {
	          ctxt.svgTextMeasurer.firstChild.remove();
	        }ctxt.svgTextMeasurer.appendChild(ctxt.svgTextMeasurer.ownerDocument.importNode(doc.documentElement, true).firstChild);
	
	        var bbox = ctxt.svgTextMeasurer.firstChild.getBBox();
	        this.bounds.width = bbox.width;
	        this.bounds.height = bbox.height;
	        this.origin.y = -bbox.y; // offset to baseline from top
	      } else if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Canvas) {
	          this.bounds.width = this.measureSubstring(ctxt);
	          this.bounds.height = this.fontSize * 1.2;
	          this.origin.y = this.fontSize;
	        }
	    }
	  }, {
	    key: 'getCssClasses',
	    value: function getCssClasses() {
	      return "";
	    }
	  }, {
	    key: 'getExtraStyleProperties',
	    value: function getExtraStyleProperties(ctxt) {
	      return "";
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      if (this.textAnchor === 'middle') canvasCtxt.textAlign = 'center';else canvasCtxt.textAlign = 'start';
	
	      canvasCtxt.font = this.fontSize + "px " + this.fontFamily;
	
	      for (var i = 0; i < this.spans.length; i++) {
	        canvasCtxt.fillText(this.spans[i].text, this.bounds.x, this.bounds.y);
	      }
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      var spans = "";
	
	      for (var i = 0; i < this.spans.length; i++) {
	        var options = {};
	
	        if (this.spans[i].properties) options['style'] = this.spans[i].properties;
	
	        spans += QuickSvg.createFragment('tspan', options, TextElement.escapeForTspan(this.spans[i].text));
	      }
	
	      var styleProperties = "font-family:" + this.fontFamily + ";font-size:" + this.fontSize + "px" + ";font-kerning:normal;" + this.getExtraStyleProperties(ctxt);
	
	      return QuickSvg.createFragment('text', {
	        'x': this.bounds.x,
	        'y': this.bounds.y,
	        'class': this.getCssClasses().trim(),
	        'text-anchor': this.textAnchor,
	        'dominant-baseline': this.dominantBaseline,
	        'style': styleProperties
	      }, spans);
	    }
	  }], [{
	    key: 'escapeForTspan',
	    value: function escapeForTspan(string) {
	      return String(string).replace(/[&<>]/g, function (s) {
	        return __subsForTspans[s];
	      });
	    }
	  }]);
	
	  return TextElement;
	}(ChantLayoutElement);
	
	var LyricType = exports.LyricType = {
	  SingleSyllable: 0,
	  BeginningSyllable: 1,
	  MiddleSyllable: 2,
	  EndingSyllable: 3,
	
	  Directive: 4 // for asterisks, "ij." elements, or other performance notes.
	};
	
	var Lyric = exports.Lyric = function (_TextElement) {
	  _inherits(Lyric, _TextElement);
	
	  function Lyric(ctxt, text, lyricType) {
	    _classCallCheck(this, Lyric);
	
	    // save the original text in case we need to later use the lyric
	    // in a dropcap...
	
	    var _this8 = _possibleConstructorReturn(this, Object.getPrototypeOf(Lyric).call(this, ctxt, text, ctxt.lyricTextFont, ctxt.lyricTextSize, 'start'));
	
	    _this8.originalText = text;
	
	    if (typeof lyricType === 'undefined' || lyricType === null || lyricType === "") _this8.lyricType = LyricType.SingleSyllable;else _this8.lyricType = lyricType;
	
	    // Lyrics keep track of how to center them on notation elements.
	    // centerTextIndex is the index in this.text where the centering starts,
	    // centerLength is how many characters comprise the center point.
	    // performLayout will do the processing
	    _this8.centerStartIndex = -1;
	    _this8.centerLength = text.length;
	
	    _this8.needsConnector = false;
	
	    // Lyrics can have their own language defined, which affects the alignment
	    // of the text with the notation element
	    _this8.language = null;
	    return _this8;
	  }
	
	  _createClass(Lyric, [{
	    key: 'allowsConnector',
	    value: function allowsConnector() {
	      return this.lyricType === LyricType.BeginningSyllable || this.lyricType === LyricType.MiddleSyllable;
	    }
	  }, {
	    key: 'setNeedsConnector',
	    value: function setNeedsConnector(needs) {
	      if (needs === true) {
	        this.needsConnector = true;
	        this.bounds.width = this.widthWithConnector;
	
	        if (this.spans.length > 0) this.spans[this.spans.length - 1].text = this.lastSpanTextWithConnector;
	      } else {
	        this.needsConnector = false;
	        this.bounds.width = this.widthWithoutConnector;
	
	        if (this.spans.length > 0) this.spans[this.spans.length - 1].text = this.lastSpanText;
	      }
	    }
	  }, {
	    key: 'generateSpansFromText',
	    value: function generateSpansFromText(ctxt, text) {
	      _get(Object.getPrototypeOf(Lyric.prototype), 'generateSpansFromText', this).call(this, ctxt, text);
	
	      if (this.spans.length > 0) {
	        this.lastSpanText = this.spans[this.spans.length - 1].text;
	        this.lastSpanTextWithConnector = this.lastSpanText + ctxt.syllableConnector;
	      } else {
	        this.lastSpanText = "";
	        this.lastSpanTextWithConnector = "";
	      }
	    }
	  }, {
	    key: 'recalculateMetrics',
	    value: function recalculateMetrics(ctxt) {
	      _get(Object.getPrototypeOf(Lyric.prototype), 'recalculateMetrics', this).call(this, ctxt);
	
	      this.widthWithoutConnector = this.bounds.width;
	      this.textWithConnector = this.text + ctxt.syllableConnector;
	
	      this.widthWithConnector = this.bounds.width + ctxt.hyphenWidth;
	
	      var activeLanguage = this.language || ctxt.defaultLanguage;
	
	      // calculate the point where the text lines up to the staff notation
	      // and offset the rect that much. By default we just center the text,
	      // but the logic below allows for smarter lyric alignment based
	      // on manual override or language control.
	      var offset = this.widthWithoutConnector / 2,
	          x1,
	          x2;
	
	      // some simple checks for sanity, and disable manual centering if the numbers are bad
	      if (this.centerStartIndex >= 0 && (this.centerStartIndex >= this.text.length || this.centerLength < 0 || this.centerStartIndex + this.centerLength > this.text.length)) this.centerStartIndex = -1;
	
	      if (this.text.length === 0) {
	        // if we have no text to work with, then there's nothing to do!
	      } else if (this.centerStartIndex >= 0) {
	          // if we have manually overriden the centering logic for this lyric,
	          // then always use that.
	          if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Svg) {
	            // svgTextMeasurer still has the current lyric in it...
	            x1 = ctxt.svgTextMeasurer.firstChild.getSubStringLength(0, this.centerStartIndex);
	            x2 = ctxt.svgTextMeasurer.firstChild.getSubStringLength(0, this.centerStartIndex + this.centerLength);
	          } else if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Canvas) {
	            x1 = this.measureSubstring(ctxt, this.centerStartIndex);
	            x2 = this.measureSubstring(ctxt, this.centerStartIndex + this.centerLength);
	          }
	          offset = x1 + (x2 - x1) / 2;
	        } else {
	
	          // if it's a directive with no manual centering override, then
	          // just center the text.
	          if (this.lyricType !== LyricType.Directive) {
	
	            // Non-directive elements are lined up to the chant notation based on vowel segments,
	            var result = activeLanguage.findVowelSegment(this.text, 0);
	
	            if (result.found === true) {
	              if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Svg) {
	                // svgTextMeasurer still has the current lyric in it...
	                x1 = ctxt.svgTextMeasurer.firstChild.getSubStringLength(0, result.startIndex);
	                x2 = ctxt.svgTextMeasurer.firstChild.getSubStringLength(0, result.startIndex + result.length);
	              } else if (ctxt.textMeasuringStrategy === TextMeasuringStrategy.Canvas) {
	                x1 = this.measureSubstring(ctxt, result.startIndex);
	                x2 = this.measureSubstring(ctxt, result.startIndex + result.length);
	              }
	              offset = x1 + (x2 - x1) / 2;
	            }
	          }
	        }
	
	      this.bounds.x = -offset;
	      this.bounds.y = 0;
	
	      this.origin.x = offset;
	
	      this.bounds.width = this.widthWithoutConnector;
	      this.bounds.height = ctxt.lyricTextSize;
	    }
	  }, {
	    key: 'generateDropCap',
	    value: function generateDropCap(ctxt) {
	
	      var dropCap = new DropCap(ctxt, this.originalText.substring(0, 1));
	
	      // if the dropcap is a single character syllable (vowel) that is the
	      // beginning of the word, then we use a hyphen in place of the lyric text
	      // and treat it as a single syllable.
	      if (this.originalText.length === 1) {
	        this.generateSpansFromText(ctxt, ctxt.syllableConnector);
	        this.centerStartIndex = -1;
	        this.lyricType = LyricType.SingleSyllable;
	      } else {
	        this.generateSpansFromText(ctxt, this.originalText.substring(1));
	        this.centerStartIndex--; // lost a letter, so adjust centering accordingly
	      }
	
	      return dropCap;
	    }
	  }, {
	    key: 'getCssClasses',
	    value: function getCssClasses() {
	
	      var classes = "lyric ";
	
	      if (this.lyricType === LyricType.Directive) classes += "directive ";
	
	      return classes + _get(Object.getPrototypeOf(Lyric.prototype), 'getCssClasses', this).call(this);
	    }
	  }, {
	    key: 'getExtraStyleProperties',
	    value: function getExtraStyleProperties(ctxt) {
	      var props = _get(Object.getPrototypeOf(Lyric.prototype), 'getExtraStyleProperties', this).call(this);
	
	      if (this.lyricType === LyricType.Directive && ctxt.autoColor === true) props += "fill:#f00;";
	
	      return props;
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      if (this.spans.length > 0) {
	        if (this.needsConnector) this.spans[this.spans.length - 1].text = this.lastSpanTextWithConnector;else this.spans[this.spans.length - 1].text = this.lastSpanText;
	      }
	
	      return _get(Object.getPrototypeOf(Lyric.prototype), 'createSvgFragment', this).call(this, ctxt);
	    }
	  }]);
	
	  return Lyric;
	}(TextElement);
	
	var DropCap = exports.DropCap = function (_TextElement2) {
	  _inherits(DropCap, _TextElement2);
	
	  /**
	   * @param {String} text
	   */
	
	  function DropCap(ctxt, text) {
	    _classCallCheck(this, DropCap);
	
	    var _this9 = _possibleConstructorReturn(this, Object.getPrototypeOf(DropCap).call(this, ctxt, text, ctxt.dropCapTextFont, ctxt.dropCapTextSize, 'middle'));
	
	    _this9.padding = ctxt.staffInterval * 2;
	    return _this9;
	  }
	
	  _createClass(DropCap, [{
	    key: 'getCssClasses',
	    value: function getCssClasses() {
	      return "dropCap " + _get(Object.getPrototypeOf(DropCap.prototype), 'getCssClasses', this).call(this);
	    }
	  }]);
	
	  return DropCap;
	}(TextElement);
	
	var Annotation = exports.Annotation = function (_TextElement3) {
	  _inherits(Annotation, _TextElement3);
	
	  /**
	   * @param {String} text
	   */
	
	  function Annotation(ctxt, text) {
	    _classCallCheck(this, Annotation);
	
	    var _this10 = _possibleConstructorReturn(this, Object.getPrototypeOf(Annotation).call(this, ctxt, text, ctxt.annotationTextFont, ctxt.annotationTextSize, 'middle'));
	
	    _this10.padding = ctxt.staffInterval;
	    _this10.dominantBaseline = 'hanging'; // so that annotations can be aligned at the top.
	    return _this10;
	  }
	
	  _createClass(Annotation, [{
	    key: 'getCssClasses',
	    value: function getCssClasses() {
	      return "annotation " + _get(Object.getPrototypeOf(Annotation.prototype), 'getCssClasses', this).call(this);
	    }
	  }]);
	
	  return Annotation;
	}(TextElement);
	
	var ChantNotationElement = exports.ChantNotationElement = function (_ChantLayoutElement8) {
	  _inherits(ChantNotationElement, _ChantLayoutElement8);
	
	  function ChantNotationElement() {
	    _classCallCheck(this, ChantNotationElement);
	
	    //double
	
	    var _this11 = _possibleConstructorReturn(this, Object.getPrototypeOf(ChantNotationElement).call(this));
	
	    _this11.leadingSpace = 0.0;
	    _this11.trailingSpace = -1; // if less than zero, this is automatically calculated at layout time
	    _this11.keepWithNext = false;
	    _this11.needsLayout = true;
	
	    _this11.lyrics = [];
	
	    _this11.score = null; // the ChantScore
	    _this11.line = null; // the ChantLine
	
	    _this11.visualizers = [];
	    return _this11;
	  }
	
	  _createClass(ChantNotationElement, [{
	    key: 'hasLyrics',
	    value: function hasLyrics() {
	      if (this.lyrics.length !== 0) return true;else return false;
	    }
	  }, {
	    key: 'getLyricLeft',
	    value: function getLyricLeft(index) {
	      // warning: no error checking on index or on whether lyric[index] is valid
	      return this.bounds.x + this.lyrics[index].bounds.x;
	    }
	  }, {
	    key: 'getAllLyricsLeft',
	    value: function getAllLyricsLeft() {
	      if (this.lyrics.length === 0) return this.bounds.right();
	
	      var x = Number.MAX_VALUE;
	      for (var i = 0; i < this.lyrics.length; i++) {
	        if (this.lyrics[i]) x = Math.min(x, this.lyrics[i].bounds.x);
	      }
	
	      return this.bounds.x + x;
	    }
	  }, {
	    key: 'getLyricRight',
	    value: function getLyricRight(index) {
	      // warning: no error checking on index or on whether lyric[index] is valid
	      return this.bounds.x + this.lyrics[index].bounds.x + this.lyrics[index].bounds.width;
	    }
	  }, {
	    key: 'getAllLyricsRight',
	    value: function getAllLyricsRight() {
	      if (this.lyrics.length === 0) return this.bounds.x;
	
	      var x = Number.MIN_VALUE;
	      for (var i = 0; i < this.lyrics.length; i++) {
	        if (this.lyrics[i]) x = Math.max(x, this.lyrics[i].bounds.x + this.lyrics[i].bounds.width);
	      }
	
	      return this.bounds.x + x;
	    }
	
	    // used by subclasses while building up the chant notations.
	
	  }, {
	    key: 'addVisualizer',
	    value: function addVisualizer(chantLayoutElement) {
	      if (this.bounds.isEmpty()) this.bounds = chantLayoutElement.bounds.clone();else this.bounds.union(chantLayoutElement.bounds);
	
	      this.visualizers.push(chantLayoutElement);
	    }
	
	    // same as addVisualizer, except the element is unshifted to the front
	    // of the visualizer array rather than the end. This way, some
	    // visualizers can be placed behind the others...ledger lines for example.
	
	  }, {
	    key: 'prependVisualizer',
	    value: function prependVisualizer(chantLayoutElement) {
	      if (this.bounds.isEmpty()) this.bounds = chantLayoutElement.bounds.clone();else this.bounds.union(chantLayoutElement.bounds);
	
	      this.visualizers.unshift(chantLayoutElement);
	    }
	
	    // chant notation elements are given an opportunity to perform their layout via this function.
	    // subclasses should call this function first in overrides of this function.
	    // on completion, exsurge presumes that the bounds, the origin, and the fragment objects are
	    // all valid and prepared for higher level layout.
	
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      if (this.trailingSpace < 0) this.trailingSpace = ctxt.intraNeumeSpacing * 4;
	
	      // reset the bounds and the staff notations before doing a layout
	      this.visualizers = [];
	      this.bounds = new _Exsurge.Rect(Infinity, Infinity, -Infinity, -Infinity);
	
	      for (var i = 0; i < this.lyrics.length; i++) {
	        this.lyrics[i].recalculateMetrics(ctxt);
	      }
	    }
	
	    // some subclasses have internal dependencies on other notations (for example,
	    // a custos can depend on a later neume which it uses to set its height).
	    // subclasses can override this function so that when the notations are
	    // altered, the subclass can correctly invalidate (and later restore) its own
	    // depedencies
	
	  }, {
	    key: 'resetDependencies',
	    value: function resetDependencies() {}
	
	    // a helper function for subclasses to call after they are done performing layout...
	
	  }, {
	    key: 'finishLayout',
	    value: function finishLayout(ctxt) {
	
	      this.bounds.x = 0;
	
	      for (var i = 0; i < this.lyrics.length; i++) {
	        this.lyrics[i].bounds.x = this.origin.x - this.lyrics[i].origin.x;
	      }this.needsLayout = false;
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	
	      var canvasCtxt = ctxt.canvasCtxt;
	      canvasCtxt.translate(this.bounds.x, 0);
	
	      for (var i = 0; i < this.visualizers.length; i++) {
	        this.visualizers[i].draw(ctxt);
	      }for (i = 0; i < this.lyrics.length; i++) {
	        this.lyrics[i].draw(ctxt);
	      }canvasCtxt.translate(-this.bounds.x, 0);
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      var inner = "";
	
	      for (var i = 0; i < this.visualizers.length; i++) {
	        inner += this.visualizers[i].createSvgFragment(ctxt);
	      }for (i = 0; i < this.lyrics.length; i++) {
	        inner += this.lyrics[i].createSvgFragment(ctxt);
	      }return QuickSvg.createFragment('g', {
	        // this.constructor.name will not be the same after being mangled by UglifyJS
	        'class': 'ChantNotationElement ' + this.constructor.name,
	        'transform': 'translate(' + this.bounds.x + ',' + 0 + ')'
	      }, inner);
	    }
	  }]);
	
	  return ChantNotationElement;
	}(ChantLayoutElement);

/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = "data:font/opentype;base64,AAEAAAATAQAABAAwRFNJRwAAAAEAAENkAAAACEdERUYAbgADAABDbAAAABhHUE9TTxtiswAAQ4QAAAE8R1NVQjtgWB4AAETAAAAAlk9TLzJKLTibAAABuAAAAGBjbWFwCRIK1gAAA4gAAAEEY3Z0IAGGB0cAAAZ0AAAAGmZwZ20GWZw3AAAEjAAAAXNnYXNwABcACAAAQ1QAAAAQZ2x5ZhRQNO4AAAdQAAAEzGhlYWQKMl2QAAABPAAAADZoaGVhDC0CmQAAAXQAAAAkaG10eB67AO4AAAIYAAABbmtlcm4E1wS9AAAMHAAAAMZsb2NhLQ4u0gAABpAAAADAbWF4cAJtAJoAAAGYAAAAIG5hbWUmgJC3AAAM5AAANY5wb3N0CJUJxAAAQnQAAADgcHJlcNTHuIYAAAYAAAAAcgABAAAAAQAArr24P18PPPUAGwgAAAAAANLrfC8AAAAA0uuXUgAA/vAFLAYhAAAACQACAAAAAAAAAAEAAAb+/bwAAAUzAAD/UQUsAAEAAAAAAAAAAAAAAAAAAABYAAEAAABfAE4AAwAAAAAAAQAAAAAACgAAAgAASwAAAAAAAwNBAZAABQAAA1gDWAAABLADWANYAAAEsABkAfQAAAIABQMGAAACAAQAAAABAAAAAAAAAAAAAAAAICAgIABAACEAfgb+/bwAAAb+AkQAAAABAAAAAAOiBOwAAAAgAAIDMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAHVAIMDMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAAEwwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAR9ACkDMwAAAzMAAAMzAAAFMwAUAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAO6AAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAAzMAAAMzAAADMwAAA4kAHwMzAAADMwAAAzMAAAQNAA8DMwAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAADAAAAHAABAAAAAAA8AAMAAQAAABwABAAgAAAABAAEAAEAAAB+//8AAAAg////4AABAAAAAAAGAMgAAAAgAF8AAAABAAIAAwAEAAUABgAHAAgACQAKAAsADAANAA4ADwAQABEAEgATABQAFQAWABcAGAAZABoAGwAcAB0AHgAfACAAIQAiACMAJAAlACYAJwAoACkAKgArACwALQAuAC8AMAAxADIAMwA0ADUANgA3ADgAOQA6ADsAPAA9AD4APwBAAEEAQgBDAEQARQBGAEcASABJAEoASwBMAE0ATgBPAFAAUQBSAFMAVABVAFYAVwBYAFkAWgBbAFwAXQBeuAAALEu4AAlQWLEBAY5ZuAH/hbgARB25AAkAA19eLbgAASwgIEVpRLABYC24AAIsuAABKiEtuAADLCBGsAMlRlJYI1kgiiCKSWSKIEYgaGFksAQlRiBoYWRSWCNlilkvILAAU1hpILAAVFghsEBZG2kgsABUWCGwQGVZWTotuAAELCBGsAQlRlJYI4pZIEYgamFksAQlRiBqYWRSWCOKWS/9LbgABSxLILADJlBYUViwgEQbsEBEWRshISBFsMBQWLDARBshWVktuAAGLCAgRWlEsAFgICBFfWkYRLABYC24AAcsuAAGKi24AAgsSyCwAyZTWLBAG7AAWYqKILADJlNYIyGwgIqKG4ojWSCwAyZTWCMhuADAioobiiNZILADJlNYIyG4AQCKihuKI1kgsAMmU1gjIbgBQIqKG4ojWSC4AAMmU1iwAyVFuAGAUFgjIbgBgCMhG7ADJUUjISMhWRshWUQtuAAJLEtTWEVEGyEhWS0AuAAAKwC6AAEAAgACKwG6AAMAAgACKwG/AAMATAA8AC8AIgAUAAAACCu/AAQARwA8AC8AIgAUAAAACCsAvwABAIAAZgBQADkAIgAAAAgrvwACAHgAZgBQADkAIgAAAAgrALoABQAEAAcruAAAIEV9aRhEAAAAKgArAFAAbgCCAAAAHv4gABQDogAeBOwAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEIAQgBCAEIAQgBCAEIAQgBCAEIAQgBCAEIAQgBCAEIAQgBCAEIAlACUAJQAlACUAJQAlACUAJQAlACUAJQAlACUAJQAlACUAQwBDAEMAQwBWAFYAVgBWAFYAVgBWAFYAVgBWAFYAagBqAGoAagBqAGoAagBqAGoAagBqAGoAagBqAGoAagBqAIcAhwCHAIcAmYCZgJmAmYCZgJmAmYCZgJmAAEAg//YAXEA7AAPAEu7AAAABAAIAAQrQRMABgAAABYAAAAmAAAANgAAAEYAAABWAAAAZgAAAHYAAACGAAAACV1BBQCVAAAApQAAAAJdALoADQAFAAMrMDElFA4CIyImNTQ+AjMyFgFxFSUzHTYuFiYzHDIxeyM7LBk6NiI7LRo7AAAAAAMAAP72BK4GIQACAB4ALAAAAQsBBwMGFhcVITU+ATcBPgE3AR4DFxUhNT4BJwMCFjcGJjcBLgEHNhYDAQL2sKsebwpKUv5gRFAKAXQXRBoBpAUSHi4g/lpOPAtyoi1ecrRIAdcBRVR70VX+OQIXAgL9/lr+sh8cCSsrDBoeBGYZKQ77Sg4WEAwEKysFHiEBTv3MDQSKE+8FHkMMCsZJ/vn7AwAAAwAp/vAFLAYbADEAPwBNAAAzNT4BNREOAQcnPgMzMh4CFRQOAgcBHgM3Fw4BIyImJwEGKwEiJicRFBYXFQMiBxEeATMyNjU0LgISFjcGJjcBLgEHNhYDATJETSNJJQkvYGhzQnSscjgpS2g+AS8PIys1IgtCdycdNw7+0Q0NGxo0HEhJRCYnGygWnqonU4HtLV5ytEgB1wFFVHvRVf45Kw4hDgQ9BQsFPgwVEQouUm9ASHVaQBP+GhYaDQEDKxYdIBcCMQIFBv4FDCMOKwS2A/4ABQKLhTdcQiX6zQ0EihPvBR5DDArGSf75+wMAAAAAAgAU/vYFCgYhABoAKAAAAQ4BBwEOAwcBLgEnNSEVDgEXCQE2Jic1IQAWNwYmNwEuAQc2FgMBBQpETQr+gQgnLiwN/kgKRT8Bs1A7CwFhAVALR1IBoPxdLV5ytEgB1wFFVHvRVf45BMENGRz7vBYfFQwDBJ0aIAgrKwYdHfxKA7QdGwor+p0NBIoT7wUeQwwKxkn++fsDAAADAAD/LwOrBOUAAgAeACwAAAELAQ8BBhYXFSE1PgE3AT4BNwEeAxcVITU+AS8BAhY3BiY3ATQmBzYWBwECNGtpHlAFKEv+oEAxBgEXFTYtAUIDCxAeJ/6bRx8GU3oOZGuBOQFhIV1xlUL+qgG5AUf+uV76ERAJNzYMEREDcBciGfw+CQ4JCAU3OAUQFPr+WwUFhxPFA/0rBgy8RNX8HAAAAwAf/y8D6wTlADEAPwBNAAAzNT4BNREiBgcnPgMzMh4CFRQOAgcTHgM3Fw4BIyImJwM2KwEiJhcRFBYXFQMiBxEeATMyNjU0LgISFjcGJjcBNCYHNhYHASc+LgI3MQoxSk9ZM1uIXCwfO1Mi3goVGCIsDT9eIR0zDN4GDBQVKgMrQkcbCwQbEG11HDhYqw5ka4E5AWEhXXGVQv6qNg0VBQM/CQdHDRENCCZFWjM5Xkk1C/6ODxEHAQQ1FhgfFQGqAQQB/oYEFg02A60B/oQBAWNlKkQuG/wJBQWHE8UD/SsGDLxE1fwcAAIAD/8vA/AE5QAaACgAAAEOAQcBDgMHAS4BJzUhFQ4BFxsBNiYnNSEAFjcGJjcBNCYHNhYHAQPwQDAF/uEHIickH/6xBio7AW5IHgb16AYmSgFg/TIOZGuBOQFhIV1xlUL+qgO5DRAQ/KwTHRIKCAOoEBQINzgGDxH9UwKrEA8KN/vHBQWHE8UD/SsGDLxE1fwcAAAAAAEAAADCAAEAHgBgAAQAVAAhAA7/nAAhACEANgAhADIADQAhADb/8gAhAEEANgAhAFIAFwAhAFb/pQAyAA7/nAAyACEAWAAyADIAoQAyADYAvQAyAEEAWAAyAFIATwAyAFYAaQA2AA7+cAA2ACH+kwA2ADL/+QA2ADYADgA2AEH+kwA2AFL/YQA2AFb/fABBAA7/nABBAFIAFwBBAFb/1QBSAA7/nABSAFIANgBSAFYATABWAA7+cABWAFIACQBWAFYAGQAAAAAAFAD2AAEAAAAAAAAALgAAAAEAAAAAAAEAEgA1AAEAAAAAAAIABwAuAAEAAAAAAAMAHwA1AAEAAAAAAAQAEgA1AAEAAAAAAAUALwBUAAEAAAAAAAYAEQCDAAEAAAAAAA0Q9ACUAAEAAAAAAA4AGgEkAAEAAAAAABIAEgA1AAMAAQQJAAAAXBGIAAMAAQQJAAEAJBHyAAMAAQQJAAIADhHkAAMAAQQJAAMAPhHyAAMAAQQJAAQAJBHyAAMAAQQJAAUAXhIwAAMAAQQJAAYAIhKOAAMAAQQJAA0h6BKwAAMAAQQJAA4ANBPQAAMAAQQJABIAJBHyQ29weXJpZ2h0IChjKSAyMDE2IEZyLiBNYXR0aGV3IFNwZW5jZXIsIE8uUy5KLlJlZ3VsYXJFeHN1cmdlIENoYXJhY3RlcnM6VmVyc2lvbiAxLjAwVmVyc2lvbiAxLjAwIEZlYnJ1YXJ5IDE4LCAyMDE2LCBpbml0aWFsIHJlbGVhc2VFeHN1cmdlQ2hhcmFjdGVyc1RoaXMgRm9udCBTb2Z0d2FyZSBpcyBsaWNlbnNlZCB1bmRlciB0aGUgU0lMIE9wZW4gRm9udCBMaWNlbnNlLCBWZXJzaW9uIDEuMS4gVGhpcyBsaWNlbnNlIGlzIGNvcGllZCBiZWxvdywgYW5kIGlzIGFsc28gYXZhaWxhYmxlIHdpdGggYSBGQVEgYXQ6IGh0dHA6Ly9zY3JpcHRzLnNpbC5vcmcvT0ZMDQoNCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NClNJTCBPUEVOIEZPTlQgTElDRU5TRSBWZXJzaW9uIDEuMSAtIDI2IEZlYnJ1YXJ5IDIwMDcNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQoNClBSRUFNQkxFDQpUaGUgZ29hbHMgb2YgdGhlIE9wZW4gRm9udCBMaWNlbnNlIChPRkwpIGFyZSB0byBzdGltdWxhdGUgd29ybGR3aWRlIGRldmVsb3BtZW50IG9mIGNvbGxhYm9yYXRpdmUgZm9udCBwcm9qZWN0cywgdG8gc3VwcG9ydCB0aGUgZm9udCBjcmVhdGlvbiBlZmZvcnRzIG9mIGFjYWRlbWljIGFuZCBsaW5ndWlzdGljIGNvbW11bml0aWVzLCBhbmQgdG8gcHJvdmlkZSBhIGZyZWUgYW5kIG9wZW4gZnJhbWV3b3JrIGluIHdoaWNoIGZvbnRzIG1heSBiZSBzaGFyZWQgYW5kIGltcHJvdmVkIGluIHBhcnRuZXJzaGlwIHdpdGggb3RoZXJzLg0KDQpUaGUgT0ZMIGFsbG93cyB0aGUgbGljZW5zZWQgZm9udHMgdG8gYmUgdXNlZCwgc3R1ZGllZCwgbW9kaWZpZWQgYW5kIHJlZGlzdHJpYnV0ZWQgZnJlZWx5IGFzIGxvbmcgYXMgdGhleSBhcmUgbm90IHNvbGQgYnkgdGhlbXNlbHZlcy4gVGhlIGZvbnRzLCBpbmNsdWRpbmcgYW55IGRlcml2YXRpdmUgd29ya3MsIGNhbiBiZSBidW5kbGVkLCBlbWJlZGRlZCwgcmVkaXN0cmlidXRlZCBhbmQvb3Igc29sZCB3aXRoIGFueSBzb2Z0d2FyZSBwcm92aWRlZCB0aGF0IGFueSByZXNlcnZlZCBuYW1lcyBhcmUgbm90IHVzZWQgYnkgZGVyaXZhdGl2ZSB3b3Jrcy4gVGhlIGZvbnRzIGFuZCBkZXJpdmF0aXZlcywgaG93ZXZlciwgY2Fubm90IGJlIHJlbGVhc2VkIHVuZGVyIGFueSBvdGhlciB0eXBlIG9mIGxpY2Vuc2UuIFRoZSByZXF1aXJlbWVudCBmb3IgZm9udHMgdG8gcmVtYWluIHVuZGVyIHRoaXMgbGljZW5zZSBkb2VzIG5vdCBhcHBseSB0byBhbnkgZG9jdW1lbnQgY3JlYXRlZCB1c2luZyB0aGUgZm9udHMgb3IgdGhlaXIgZGVyaXZhdGl2ZXMuDQoNCkRFRklOSVRJT05TDQoiRm9udCBTb2Z0d2FyZSIgcmVmZXJzIHRvIHRoZSBzZXQgb2YgZmlsZXMgcmVsZWFzZWQgYnkgdGhlIENvcHlyaWdodCBIb2xkZXIocykgdW5kZXIgdGhpcyBsaWNlbnNlIGFuZCBjbGVhcmx5IG1hcmtlZCBhcyBzdWNoLiBUaGlzIG1heSBpbmNsdWRlIHNvdXJjZSBmaWxlcywgYnVpbGQgc2NyaXB0cyBhbmQgZG9jdW1lbnRhdGlvbi4NCg0KIlJlc2VydmVkIEZvbnQgTmFtZSIgcmVmZXJzIHRvIGFueSBuYW1lcyBzcGVjaWZpZWQgYXMgc3VjaCBhZnRlciB0aGUgY29weXJpZ2h0IHN0YXRlbWVudChzKS4NCg0KIk9yaWdpbmFsIFZlcnNpb24iIHJlZmVycyB0byB0aGUgY29sbGVjdGlvbiBvZiBGb250IFNvZnR3YXJlIGNvbXBvbmVudHMgYXMgZGlzdHJpYnV0ZWQgYnkgdGhlIENvcHlyaWdodCBIb2xkZXIocykuDQoNCiJNb2RpZmllZCBWZXJzaW9uIiByZWZlcnMgdG8gYW55IGRlcml2YXRpdmUgbWFkZSBieSBhZGRpbmcgdG8sIGRlbGV0aW5nLCBvciBzdWJzdGl0dXRpbmcgLS0gaW4gcGFydCBvciBpbiB3aG9sZSAtLSBhbnkgb2YgdGhlIGNvbXBvbmVudHMgb2YgdGhlIE9yaWdpbmFsIFZlcnNpb24sIGJ5IGNoYW5naW5nIGZvcm1hdHMgb3IgYnkgcG9ydGluZyB0aGUgRm9udCBTb2Z0d2FyZSB0byBhIG5ldyBlbnZpcm9ubWVudC4NCg0KIkF1dGhvciIgcmVmZXJzIHRvIGFueSBkZXNpZ25lciwgZW5naW5lZXIsIHByb2dyYW1tZXIsIHRlY2huaWNhbCB3cml0ZXIgb3Igb3RoZXIgcGVyc29uIHdobyBjb250cmlidXRlZCB0byB0aGUgRm9udCBTb2Z0d2FyZS4NCg0KUEVSTUlTU0lPTiAmIENPTkRJVElPTlMNClBlcm1pc3Npb24gaXMgaGVyZWJ5IGdyYW50ZWQsIGZyZWUgb2YgY2hhcmdlLCB0byBhbnkgcGVyc29uIG9idGFpbmluZyBhIGNvcHkgb2YgdGhlIEZvbnQgU29mdHdhcmUsIHRvIHVzZSwgc3R1ZHksIGNvcHksIG1lcmdlLCBlbWJlZCwgbW9kaWZ5LCByZWRpc3RyaWJ1dGUsIGFuZCBzZWxsIG1vZGlmaWVkIGFuZCB1bm1vZGlmaWVkIGNvcGllcyBvZiB0aGUgRm9udCBTb2Z0d2FyZSwgc3ViamVjdCB0byB0aGUgZm9sbG93aW5nIGNvbmRpdGlvbnM6DQoNCjEpIE5laXRoZXIgdGhlIEZvbnQgU29mdHdhcmUgbm9yIGFueSBvZiBpdHMgaW5kaXZpZHVhbCBjb21wb25lbnRzLCBpbiBPcmlnaW5hbCBvciBNb2RpZmllZCBWZXJzaW9ucywgbWF5IGJlIHNvbGQgYnkgaXRzZWxmLg0KDQoyKSBPcmlnaW5hbCBvciBNb2RpZmllZCBWZXJzaW9ucyBvZiB0aGUgRm9udCBTb2Z0d2FyZSBtYXkgYmUgYnVuZGxlZCwgcmVkaXN0cmlidXRlZCBhbmQvb3Igc29sZCB3aXRoIGFueSBzb2Z0d2FyZSwgcHJvdmlkZWQgdGhhdCBlYWNoIGNvcHkgY29udGFpbnMgdGhlIGFib3ZlIGNvcHlyaWdodCBub3RpY2UgYW5kIHRoaXMgbGljZW5zZS4gVGhlc2UgY2FuIGJlIGluY2x1ZGVkIGVpdGhlciBhcyBzdGFuZC1hbG9uZSB0ZXh0IGZpbGVzLCBodW1hbi1yZWFkYWJsZSBoZWFkZXJzIG9yIGluIHRoZSBhcHByb3ByaWF0ZSBtYWNoaW5lLXJlYWRhYmxlIG1ldGFkYXRhIGZpZWxkcyB3aXRoaW4gdGV4dCBvciBiaW5hcnkgZmlsZXMgYXMgbG9uZyBhcyB0aG9zZSBmaWVsZHMgY2FuIGJlIGVhc2lseSB2aWV3ZWQgYnkgdGhlIHVzZXIuDQoNCjMpIE5vIE1vZGlmaWVkIFZlcnNpb24gb2YgdGhlIEZvbnQgU29mdHdhcmUgbWF5IHVzZSB0aGUgUmVzZXJ2ZWQgRm9udCBOYW1lKHMpIHVubGVzcyBleHBsaWNpdCB3cml0dGVuIHBlcm1pc3Npb24gaXMgZ3JhbnRlZCBieSB0aGUgY29ycmVzcG9uZGluZyBDb3B5cmlnaHQgSG9sZGVyLiBUaGlzIHJlc3RyaWN0aW9uIG9ubHkgYXBwbGllcyB0byB0aGUgcHJpbWFyeSBmb250IG5hbWUgYXMgcHJlc2VudGVkIHRvIHRoZSB1c2Vycy4NCg0KNCkgVGhlIG5hbWUocykgb2YgdGhlIENvcHlyaWdodCBIb2xkZXIocykgb3IgdGhlIEF1dGhvcihzKSBvZiB0aGUgRm9udCBTb2Z0d2FyZSBzaGFsbCBub3QgYmUgdXNlZCB0byBwcm9tb3RlLCBlbmRvcnNlIG9yIGFkdmVydGlzZSBhbnkgTW9kaWZpZWQgVmVyc2lvbiwgZXhjZXB0IHRvIGFja25vd2xlZGdlIHRoZSBjb250cmlidXRpb24ocykgb2YgdGhlIENvcHlyaWdodCBIb2xkZXIocykgYW5kIHRoZSBBdXRob3Iocykgb3Igd2l0aCB0aGVpciBleHBsaWNpdCB3cml0dGVuIHBlcm1pc3Npb24uDQoNCjUpIFRoZSBGb250IFNvZnR3YXJlLCBtb2RpZmllZCBvciB1bm1vZGlmaWVkLCBpbiBwYXJ0IG9yIGluIHdob2xlLCBtdXN0IGJlIGRpc3RyaWJ1dGVkIGVudGlyZWx5IHVuZGVyIHRoaXMgbGljZW5zZSwgYW5kIG11c3Qgbm90IGJlIGRpc3RyaWJ1dGVkIHVuZGVyIGFueSBvdGhlciBsaWNlbnNlLiBUaGUgcmVxdWlyZW1lbnQgZm9yIGZvbnRzIHRvIHJlbWFpbiB1bmRlciB0aGlzIGxpY2Vuc2UgZG9lcyBub3QgYXBwbHkgdG8gYW55IGRvY3VtZW50IGNyZWF0ZWQgdXNpbmcgdGhlIEZvbnQgU29mdHdhcmUuDQoNClRFUk1JTkFUSU9ODQpUaGlzIGxpY2Vuc2UgYmVjb21lcyBudWxsIGFuZCB2b2lkIGlmIGFueSBvZiB0aGUgYWJvdmUgY29uZGl0aW9ucyBhcmUgbm90IG1ldC4NCg0KRElTQ0xBSU1FUg0KVEhFIEZPTlQgU09GVFdBUkUgSVMgUFJPVklERUQgIkFTIElTIiwgV0lUSE9VVCBXQVJSQU5UWSBPRiBBTlkgS0lORCwgRVhQUkVTUyBPUiBJTVBMSUVELCBJTkNMVURJTkcgQlVUIE5PVCBMSU1JVEVEIFRPIEFOWSBXQVJSQU5USUVTIE9GIE1FUkNIQU5UQUJJTElUWSwgRklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UgQU5EIE5PTklORlJJTkdFTUVOVCBPRiBDT1BZUklHSFQsIFBBVEVOVCwgVFJBREVNQVJLLCBPUiBPVEhFUiBSSUdIVC4gSU4gTk8gRVZFTlQgU0hBTEwgVEhFIENPUFlSSUdIVCBIT0xERVIgQkUgTElBQkxFIEZPUiBBTlkgQ0xBSU0sIERBTUFHRVMgT1IgT1RIRVIgTElBQklMSVRZLCBJTkNMVURJTkcgQU5ZIEdFTkVSQUwsIFNQRUNJQUwsIElORElSRUNULCBJTkNJREVOVEFMLCBPUiBDT05TRVFVRU5USUFMIERBTUFHRVMsIFdIRVRIRVIgSU4gQU4gQUNUSU9OIE9GIENPTlRSQUNULCBUT1JUIE9SIE9USEVSV0lTRSwgQVJJU0lORyBGUk9NLCBPVVQgT0YgVEhFIFVTRSBPUiBJTkFCSUxJVFkgVE8gVVNFIFRIRSBGT05UIFNPRlRXQVJFIE9SIEZST00gT1RIRVIgREVBTElOR1MgSU4gVEhFIEZPTlQgU09GVFdBUkUuAEMAbwBwAHkAcgBpAGcAaAB0ACAAKABjACkAIAAyADAAMQA2ACAARgByAC4AIABNAGEAdAB0AGgAZQB3ACAAUwBwAGUAbgBjAGUAcgAsACAATwAuAFMALgBKAC4AUgBlAGcAdQBsAGEAcgBFAHgAcwB1AHIAZwBlACAAQwBoAGEAcgBhAGMAdABlAHIAcwA6AFYAZQByAHMAaQBvAG4AIAAxAC4AMAAwAFYAZQByAHMAaQBvAG4AIAAxAC4AMAAwACAARgBlAGIAcgB1AGEAcgB5ACAAMQA4ACwAIAAyADAAMQA2ACwAIABpAG4AaQB0AGkAYQBsACAAcgBlAGwAZQBhAHMAZQBFAHgAcwB1AHIAZwBlAEMAaABhAHIAYQBjAHQAZQByAHMAVABoAGkAcwAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUAIABpAHMAIABsAGkAYwBlAG4AcwBlAGQAIAB1AG4AZABlAHIAIAB0AGgAZQAgAFMASQBMACAATwBwAGUAbgAgAEYAbwBuAHQAIABMAGkAYwBlAG4AcwBlACwAIABWAGUAcgBzAGkAbwBuACAAMQAuADEALgAgAFQAaABpAHMAIABsAGkAYwBlAG4AcwBlACAAaQBzACAAYwBvAHAAaQBlAGQAIABiAGUAbABvAHcALAAgAGEAbgBkACAAaQBzACAAYQBsAHMAbwAgAGEAdgBhAGkAbABhAGIAbABlACAAdwBpAHQAaAAgAGEAIABGAEEAUQAgAGEAdAA6ACAAaAB0AHQAcAA6AC8ALwBzAGMAcgBpAHAAdABzAC4AcwBpAGwALgBvAHIAZwAvAE8ARgBMAA0ACgANAAoADQAKAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQANAAoAUwBJAEwAIABPAFAARQBOACAARgBPAE4AVAAgAEwASQBDAEUATgBTAEUAIABWAGUAcgBzAGkAbwBuACAAMQAuADEAIAAtACAAMgA2ACAARgBlAGIAcgB1AGEAcgB5ACAAMgAwADAANwANAAoALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAA0ACgANAAoAUABSAEUAQQBNAEIATABFAA0ACgBUAGgAZQAgAGcAbwBhAGwAcwAgAG8AZgAgAHQAaABlACAATwBwAGUAbgAgAEYAbwBuAHQAIABMAGkAYwBlAG4AcwBlACAAKABPAEYATAApACAAYQByAGUAIAB0AG8AIABzAHQAaQBtAHUAbABhAHQAZQAgAHcAbwByAGwAZAB3AGkAZABlACAAZABlAHYAZQBsAG8AcABtAGUAbgB0ACAAbwBmACAAYwBvAGwAbABhAGIAbwByAGEAdABpAHYAZQAgAGYAbwBuAHQAIABwAHIAbwBqAGUAYwB0AHMALAAgAHQAbwAgAHMAdQBwAHAAbwByAHQAIAB0AGgAZQAgAGYAbwBuAHQAIABjAHIAZQBhAHQAaQBvAG4AIABlAGYAZgBvAHIAdABzACAAbwBmACAAYQBjAGEAZABlAG0AaQBjACAAYQBuAGQAIABsAGkAbgBnAHUAaQBzAHQAaQBjACAAYwBvAG0AbQB1AG4AaQB0AGkAZQBzACwAIABhAG4AZAAgAHQAbwAgAHAAcgBvAHYAaQBkAGUAIABhACAAZgByAGUAZQAgAGEAbgBkACAAbwBwAGUAbgAgAGYAcgBhAG0AZQB3AG8AcgBrACAAaQBuACAAdwBoAGkAYwBoACAAZgBvAG4AdABzACAAbQBhAHkAIABiAGUAIABzAGgAYQByAGUAZAAgAGEAbgBkACAAaQBtAHAAcgBvAHYAZQBkACAAaQBuACAAcABhAHIAdABuAGUAcgBzAGgAaQBwACAAdwBpAHQAaAAgAG8AdABoAGUAcgBzAC4ADQAKAA0ACgBUAGgAZQAgAE8ARgBMACAAYQBsAGwAbwB3AHMAIAB0AGgAZQAgAGwAaQBjAGUAbgBzAGUAZAAgAGYAbwBuAHQAcwAgAHQAbwAgAGIAZQAgAHUAcwBlAGQALAAgAHMAdAB1AGQAaQBlAGQALAAgAG0AbwBkAGkAZgBpAGUAZAAgAGEAbgBkACAAcgBlAGQAaQBzAHQAcgBpAGIAdQB0AGUAZAAgAGYAcgBlAGUAbAB5ACAAYQBzACAAbABvAG4AZwAgAGEAcwAgAHQAaABlAHkAIABhAHIAZQAgAG4AbwB0ACAAcwBvAGwAZAAgAGIAeQAgAHQAaABlAG0AcwBlAGwAdgBlAHMALgAgAFQAaABlACAAZgBvAG4AdABzACwAIABpAG4AYwBsAHUAZABpAG4AZwAgAGEAbgB5ACAAZABlAHIAaQB2AGEAdABpAHYAZQAgAHcAbwByAGsAcwAsACAAYwBhAG4AIABiAGUAIABiAHUAbgBkAGwAZQBkACwAIABlAG0AYgBlAGQAZABlAGQALAAgAHIAZQBkAGkAcwB0AHIAaQBiAHUAdABlAGQAIABhAG4AZAAvAG8AcgAgAHMAbwBsAGQAIAB3AGkAdABoACAAYQBuAHkAIABzAG8AZgB0AHcAYQByAGUAIABwAHIAbwB2AGkAZABlAGQAIAB0AGgAYQB0ACAAYQBuAHkAIAByAGUAcwBlAHIAdgBlAGQAIABuAGEAbQBlAHMAIABhAHIAZQAgAG4AbwB0ACAAdQBzAGUAZAAgAGIAeQAgAGQAZQByAGkAdgBhAHQAaQB2AGUAIAB3AG8AcgBrAHMALgAgAFQAaABlACAAZgBvAG4AdABzACAAYQBuAGQAIABkAGUAcgBpAHYAYQB0AGkAdgBlAHMALAAgAGgAbwB3AGUAdgBlAHIALAAgAGMAYQBuAG4AbwB0ACAAYgBlACAAcgBlAGwAZQBhAHMAZQBkACAAdQBuAGQAZQByACAAYQBuAHkAIABvAHQAaABlAHIAIAB0AHkAcABlACAAbwBmACAAbABpAGMAZQBuAHMAZQAuACAAVABoAGUAIAByAGUAcQB1AGkAcgBlAG0AZQBuAHQAIABmAG8AcgAgAGYAbwBuAHQAcwAgAHQAbwAgAHIAZQBtAGEAaQBuACAAdQBuAGQAZQByACAAdABoAGkAcwAgAGwAaQBjAGUAbgBzAGUAIABkAG8AZQBzACAAbgBvAHQAIABhAHAAcABsAHkAIAB0AG8AIABhAG4AeQAgAGQAbwBjAHUAbQBlAG4AdAAgAGMAcgBlAGEAdABlAGQAIAB1AHMAaQBuAGcAIAB0AGgAZQAgAGYAbwBuAHQAcwAgAG8AcgAgAHQAaABlAGkAcgAgAGQAZQByAGkAdgBhAHQAaQB2AGUAcwAuAA0ACgANAAoARABFAEYASQBOAEkAVABJAE8ATgBTAA0ACgAiAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUAIgAgAHIAZQBmAGUAcgBzACAAdABvACAAdABoAGUAIABzAGUAdAAgAG8AZgAgAGYAaQBsAGUAcwAgAHIAZQBsAGUAYQBzAGUAZAAgAGIAeQAgAHQAaABlACAAQwBvAHAAeQByAGkAZwBoAHQAIABIAG8AbABkAGUAcgAoAHMAKQAgAHUAbgBkAGUAcgAgAHQAaABpAHMAIABsAGkAYwBlAG4AcwBlACAAYQBuAGQAIABjAGwAZQBhAHIAbAB5ACAAbQBhAHIAawBlAGQAIABhAHMAIABzAHUAYwBoAC4AIABUAGgAaQBzACAAbQBhAHkAIABpAG4AYwBsAHUAZABlACAAcwBvAHUAcgBjAGUAIABmAGkAbABlAHMALAAgAGIAdQBpAGwAZAAgAHMAYwByAGkAcAB0AHMAIABhAG4AZAAgAGQAbwBjAHUAbQBlAG4AdABhAHQAaQBvAG4ALgANAAoADQAKACIAUgBlAHMAZQByAHYAZQBkACAARgBvAG4AdAAgAE4AYQBtAGUAIgAgAHIAZQBmAGUAcgBzACAAdABvACAAYQBuAHkAIABuAGEAbQBlAHMAIABzAHAAZQBjAGkAZgBpAGUAZAAgAGEAcwAgAHMAdQBjAGgAIABhAGYAdABlAHIAIAB0AGgAZQAgAGMAbwBwAHkAcgBpAGcAaAB0ACAAcwB0AGEAdABlAG0AZQBuAHQAKABzACkALgANAAoADQAKACIATwByAGkAZwBpAG4AYQBsACAAVgBlAHIAcwBpAG8AbgAiACAAcgBlAGYAZQByAHMAIAB0AG8AIAB0AGgAZQAgAGMAbwBsAGwAZQBjAHQAaQBvAG4AIABvAGYAIABGAG8AbgB0ACAAUwBvAGYAdAB3AGEAcgBlACAAYwBvAG0AcABvAG4AZQBuAHQAcwAgAGEAcwAgAGQAaQBzAHQAcgBpAGIAdQB0AGUAZAAgAGIAeQAgAHQAaABlACAAQwBvAHAAeQByAGkAZwBoAHQAIABIAG8AbABkAGUAcgAoAHMAKQAuAA0ACgANAAoAIgBNAG8AZABpAGYAaQBlAGQAIABWAGUAcgBzAGkAbwBuACIAIAByAGUAZgBlAHIAcwAgAHQAbwAgAGEAbgB5ACAAZABlAHIAaQB2AGEAdABpAHYAZQAgAG0AYQBkAGUAIABiAHkAIABhAGQAZABpAG4AZwAgAHQAbwAsACAAZABlAGwAZQB0AGkAbgBnACwAIABvAHIAIABzAHUAYgBzAHQAaQB0AHUAdABpAG4AZwAgAC0ALQAgAGkAbgAgAHAAYQByAHQAIABvAHIAIABpAG4AIAB3AGgAbwBsAGUAIAAtAC0AIABhAG4AeQAgAG8AZgAgAHQAaABlACAAYwBvAG0AcABvAG4AZQBuAHQAcwAgAG8AZgAgAHQAaABlACAATwByAGkAZwBpAG4AYQBsACAAVgBlAHIAcwBpAG8AbgAsACAAYgB5ACAAYwBoAGEAbgBnAGkAbgBnACAAZgBvAHIAbQBhAHQAcwAgAG8AcgAgAGIAeQAgAHAAbwByAHQAaQBuAGcAIAB0AGgAZQAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUAIAB0AG8AIABhACAAbgBlAHcAIABlAG4AdgBpAHIAbwBuAG0AZQBuAHQALgANAAoADQAKACIAQQB1AHQAaABvAHIAIgAgAHIAZQBmAGUAcgBzACAAdABvACAAYQBuAHkAIABkAGUAcwBpAGcAbgBlAHIALAAgAGUAbgBnAGkAbgBlAGUAcgAsACAAcAByAG8AZwByAGEAbQBtAGUAcgAsACAAdABlAGMAaABuAGkAYwBhAGwAIAB3AHIAaQB0AGUAcgAgAG8AcgAgAG8AdABoAGUAcgAgAHAAZQByAHMAbwBuACAAdwBoAG8AIABjAG8AbgB0AHIAaQBiAHUAdABlAGQAIAB0AG8AIAB0AGgAZQAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUALgANAAoADQAKAFAARQBSAE0ASQBTAFMASQBPAE4AIAAmACAAQwBPAE4ARABJAFQASQBPAE4AUwANAAoAUABlAHIAbQBpAHMAcwBpAG8AbgAgAGkAcwAgAGgAZQByAGUAYgB5ACAAZwByAGEAbgB0AGUAZAAsACAAZgByAGUAZQAgAG8AZgAgAGMAaABhAHIAZwBlACwAIAB0AG8AIABhAG4AeQAgAHAAZQByAHMAbwBuACAAbwBiAHQAYQBpAG4AaQBuAGcAIABhACAAYwBvAHAAeQAgAG8AZgAgAHQAaABlACAARgBvAG4AdAAgAFMAbwBmAHQAdwBhAHIAZQAsACAAdABvACAAdQBzAGUALAAgAHMAdAB1AGQAeQAsACAAYwBvAHAAeQAsACAAbQBlAHIAZwBlACwAIABlAG0AYgBlAGQALAAgAG0AbwBkAGkAZgB5ACwAIAByAGUAZABpAHMAdAByAGkAYgB1AHQAZQAsACAAYQBuAGQAIABzAGUAbABsACAAbQBvAGQAaQBmAGkAZQBkACAAYQBuAGQAIAB1AG4AbQBvAGQAaQBmAGkAZQBkACAAYwBvAHAAaQBlAHMAIABvAGYAIAB0AGgAZQAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUALAAgAHMAdQBiAGoAZQBjAHQAIAB0AG8AIAB0AGgAZQAgAGYAbwBsAGwAbwB3AGkAbgBnACAAYwBvAG4AZABpAHQAaQBvAG4AcwA6AA0ACgANAAoAMQApACAATgBlAGkAdABoAGUAcgAgAHQAaABlACAARgBvAG4AdAAgAFMAbwBmAHQAdwBhAHIAZQAgAG4AbwByACAAYQBuAHkAIABvAGYAIABpAHQAcwAgAGkAbgBkAGkAdgBpAGQAdQBhAGwAIABjAG8AbQBwAG8AbgBlAG4AdABzACwAIABpAG4AIABPAHIAaQBnAGkAbgBhAGwAIABvAHIAIABNAG8AZABpAGYAaQBlAGQAIABWAGUAcgBzAGkAbwBuAHMALAAgAG0AYQB5ACAAYgBlACAAcwBvAGwAZAAgAGIAeQAgAGkAdABzAGUAbABmAC4ADQAKAA0ACgAyACkAIABPAHIAaQBnAGkAbgBhAGwAIABvAHIAIABNAG8AZABpAGYAaQBlAGQAIABWAGUAcgBzAGkAbwBuAHMAIABvAGYAIAB0AGgAZQAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUAIABtAGEAeQAgAGIAZQAgAGIAdQBuAGQAbABlAGQALAAgAHIAZQBkAGkAcwB0AHIAaQBiAHUAdABlAGQAIABhAG4AZAAvAG8AcgAgAHMAbwBsAGQAIAB3AGkAdABoACAAYQBuAHkAIABzAG8AZgB0AHcAYQByAGUALAAgAHAAcgBvAHYAaQBkAGUAZAAgAHQAaABhAHQAIABlAGEAYwBoACAAYwBvAHAAeQAgAGMAbwBuAHQAYQBpAG4AcwAgAHQAaABlACAAYQBiAG8AdgBlACAAYwBvAHAAeQByAGkAZwBoAHQAIABuAG8AdABpAGMAZQAgAGEAbgBkACAAdABoAGkAcwAgAGwAaQBjAGUAbgBzAGUALgAgAFQAaABlAHMAZQAgAGMAYQBuACAAYgBlACAAaQBuAGMAbAB1AGQAZQBkACAAZQBpAHQAaABlAHIAIABhAHMAIABzAHQAYQBuAGQALQBhAGwAbwBuAGUAIAB0AGUAeAB0ACAAZgBpAGwAZQBzACwAIABoAHUAbQBhAG4ALQByAGUAYQBkAGEAYgBsAGUAIABoAGUAYQBkAGUAcgBzACAAbwByACAAaQBuACAAdABoAGUAIABhAHAAcAByAG8AcAByAGkAYQB0AGUAIABtAGEAYwBoAGkAbgBlAC0AcgBlAGEAZABhAGIAbABlACAAbQBlAHQAYQBkAGEAdABhACAAZgBpAGUAbABkAHMAIAB3AGkAdABoAGkAbgAgAHQAZQB4AHQAIABvAHIAIABiAGkAbgBhAHIAeQAgAGYAaQBsAGUAcwAgAGEAcwAgAGwAbwBuAGcAIABhAHMAIAB0AGgAbwBzAGUAIABmAGkAZQBsAGQAcwAgAGMAYQBuACAAYgBlACAAZQBhAHMAaQBsAHkAIAB2AGkAZQB3AGUAZAAgAGIAeQAgAHQAaABlACAAdQBzAGUAcgAuAA0ACgANAAoAMwApACAATgBvACAATQBvAGQAaQBmAGkAZQBkACAAVgBlAHIAcwBpAG8AbgAgAG8AZgAgAHQAaABlACAARgBvAG4AdAAgAFMAbwBmAHQAdwBhAHIAZQAgAG0AYQB5ACAAdQBzAGUAIAB0AGgAZQAgAFIAZQBzAGUAcgB2AGUAZAAgAEYAbwBuAHQAIABOAGEAbQBlACgAcwApACAAdQBuAGwAZQBzAHMAIABlAHgAcABsAGkAYwBpAHQAIAB3AHIAaQB0AHQAZQBuACAAcABlAHIAbQBpAHMAcwBpAG8AbgAgAGkAcwAgAGcAcgBhAG4AdABlAGQAIABiAHkAIAB0AGgAZQAgAGMAbwByAHIAZQBzAHAAbwBuAGQAaQBuAGcAIABDAG8AcAB5AHIAaQBnAGgAdAAgAEgAbwBsAGQAZQByAC4AIABUAGgAaQBzACAAcgBlAHMAdAByAGkAYwB0AGkAbwBuACAAbwBuAGwAeQAgAGEAcABwAGwAaQBlAHMAIAB0AG8AIAB0AGgAZQAgAHAAcgBpAG0AYQByAHkAIABmAG8AbgB0ACAAbgBhAG0AZQAgAGEAcwAgAHAAcgBlAHMAZQBuAHQAZQBkACAAdABvACAAdABoAGUAIAB1AHMAZQByAHMALgANAAoADQAKADQAKQAgAFQAaABlACAAbgBhAG0AZQAoAHMAKQAgAG8AZgAgAHQAaABlACAAQwBvAHAAeQByAGkAZwBoAHQAIABIAG8AbABkAGUAcgAoAHMAKQAgAG8AcgAgAHQAaABlACAAQQB1AHQAaABvAHIAKABzACkAIABvAGYAIAB0AGgAZQAgAEYAbwBuAHQAIABTAG8AZgB0AHcAYQByAGUAIABzAGgAYQBsAGwAIABuAG8AdAAgAGIAZQAgAHUAcwBlAGQAIAB0AG8AIABwAHIAbwBtAG8AdABlACwAIABlAG4AZABvAHIAcwBlACAAbwByACAAYQBkAHYAZQByAHQAaQBzAGUAIABhAG4AeQAgAE0AbwBkAGkAZgBpAGUAZAAgAFYAZQByAHMAaQBvAG4ALAAgAGUAeABjAGUAcAB0ACAAdABvACAAYQBjAGsAbgBvAHcAbABlAGQAZwBlACAAdABoAGUAIABjAG8AbgB0AHIAaQBiAHUAdABpAG8AbgAoAHMAKQAgAG8AZgAgAHQAaABlACAAQwBvAHAAeQByAGkAZwBoAHQAIABIAG8AbABkAGUAcgAoAHMAKQAgAGEAbgBkACAAdABoAGUAIABBAHUAdABoAG8AcgAoAHMAKQAgAG8AcgAgAHcAaQB0AGgAIAB0AGgAZQBpAHIAIABlAHgAcABsAGkAYwBpAHQAIAB3AHIAaQB0AHQAZQBuACAAcABlAHIAbQBpAHMAcwBpAG8AbgAuAA0ACgANAAoANQApACAAVABoAGUAIABGAG8AbgB0ACAAUwBvAGYAdAB3AGEAcgBlACwAIABtAG8AZABpAGYAaQBlAGQAIABvAHIAIAB1AG4AbQBvAGQAaQBmAGkAZQBkACwAIABpAG4AIABwAGEAcgB0ACAAbwByACAAaQBuACAAdwBoAG8AbABlACwAIABtAHUAcwB0ACAAYgBlACAAZABpAHMAdAByAGkAYgB1AHQAZQBkACAAZQBuAHQAaQByAGUAbAB5ACAAdQBuAGQAZQByACAAdABoAGkAcwAgAGwAaQBjAGUAbgBzAGUALAAgAGEAbgBkACAAbQB1AHMAdAAgAG4AbwB0ACAAYgBlACAAZABpAHMAdAByAGkAYgB1AHQAZQBkACAAdQBuAGQAZQByACAAYQBuAHkAIABvAHQAaABlAHIAIABsAGkAYwBlAG4AcwBlAC4AIABUAGgAZQAgAHIAZQBxAHUAaQByAGUAbQBlAG4AdAAgAGYAbwByACAAZgBvAG4AdABzACAAdABvACAAcgBlAG0AYQBpAG4AIAB1AG4AZABlAHIAIAB0AGgAaQBzACAAbABpAGMAZQBuAHMAZQAgAGQAbwBlAHMAIABuAG8AdAAgAGEAcABwAGwAeQAgAHQAbwAgAGEAbgB5ACAAZABvAGMAdQBtAGUAbgB0ACAAYwByAGUAYQB0AGUAZAAgAHUAcwBpAG4AZwAgAHQAaABlACAARgBvAG4AdAAgAFMAbwBmAHQAdwBhAHIAZQAuAA0ACgANAAoAVABFAFIATQBJAE4AQQBUAEkATwBOAA0ACgBUAGgAaQBzACAAbABpAGMAZQBuAHMAZQAgAGIAZQBjAG8AbQBlAHMAIABuAHUAbABsACAAYQBuAGQAIAB2AG8AaQBkACAAaQBmACAAYQBuAHkAIABvAGYAIAB0AGgAZQAgAGEAYgBvAHYAZQAgAGMAbwBuAGQAaQB0AGkAbwBuAHMAIABhAHIAZQAgAG4AbwB0ACAAbQBlAHQALgANAAoADQAKAEQASQBTAEMATABBAEkATQBFAFIADQAKAFQASABFACAARgBPAE4AVAAgAFMATwBGAFQAVwBBAFIARQAgAEkAUwAgAFAAUgBPAFYASQBEAEUARAAgACIAQQBTACAASQBTACIALAAgAFcASQBUAEgATwBVAFQAIABXAEEAUgBSAEEATgBUAFkAIABPAEYAIABBAE4AWQAgAEsASQBOAEQALAAgAEUAWABQAFIARQBTAFMAIABPAFIAIABJAE0AUABMAEkARQBEACwAIABJAE4AQwBMAFUARABJAE4ARwAgAEIAVQBUACAATgBPAFQAIABMAEkATQBJAFQARQBEACAAVABPACAAQQBOAFkAIABXAEEAUgBSAEEATgBUAEkARQBTACAATwBGACAATQBFAFIAQwBIAEEATgBUAEEAQgBJAEwASQBUAFkALAAgAEYASQBUAE4ARQBTAFMAIABGAE8AUgAgAEEAIABQAEEAUgBUAEkAQwBVAEwAQQBSACAAUABVAFIAUABPAFMARQAgAEEATgBEACAATgBPAE4ASQBOAEYAUgBJAE4ARwBFAE0ARQBOAFQAIABPAEYAIABDAE8AUABZAFIASQBHAEgAVAAsACAAUABBAFQARQBOAFQALAAgAFQAUgBBAEQARQBNAEEAUgBLACwAIABPAFIAIABPAFQASABFAFIAIABSAEkARwBIAFQALgAgAEkATgAgAE4ATwAgAEUAVgBFAE4AVAAgAFMASABBAEwATAAgAFQASABFACAAQwBPAFAAWQBSAEkARwBIAFQAIABIAE8ATABEAEUAUgAgAEIARQAgAEwASQBBAEIATABFACAARgBPAFIAIABBAE4AWQAgAEMATABBAEkATQAsACAARABBAE0AQQBHAEUAUwAgAE8AUgAgAE8AVABIAEUAUgAgAEwASQBBAEIASQBMAEkAVABZACwAIABJAE4AQwBMAFUARABJAE4ARwAgAEEATgBZACAARwBFAE4ARQBSAEEATAAsACAAUwBQAEUAQwBJAEEATAAsACAASQBOAEQASQBSAEUAQwBUACwAIABJAE4AQwBJAEQARQBOAFQAQQBMACwAIABPAFIAIABDAE8ATgBTAEUAUQBVAEUATgBUAEkAQQBMACAARABBAE0AQQBHAEUAUwAsACAAVwBIAEUAVABIAEUAUgAgAEkATgAgAEEATgAgAEEAQwBUAEkATwBOACAATwBGACAAQwBPAE4AVABSAEEAQwBUACwAIABUAE8AUgBUACAATwBSACAATwBUAEgARQBSAFcASQBTAEUALAAgAEEAUgBJAFMASQBOAEcAIABGAFIATwBNACwAIABPAFUAVAAgAE8ARgAgAFQASABFACAAVQBTAEUAIABPAFIAIABJAE4AQQBCAEkATABJAFQAWQAgAFQATwAgAFUAUwBFACAAVABIAEUAIABGAE8ATgBUACAAUwBPAEYAVABXAEEAUgBFACAATwBSACAARgBSAE8ATQAgAE8AVABIAEUAUgAgAEQARQBBAEwASQBOAEcAUwAgAEkATgAgAFQASABFACAARgBPAE4AVAAgAFMATwBGAFQAVwBBAFIARQAuAAAAAgAAAAAAAP8GAGQAAAAAAAAAAAAAAAAAAAAAAAAAAABfAAMABAAFAAYABwAIAAkACgALAAwADQAOAA8AEAARABIAEwAUABUAFgAXABgAGQAaABsAHAAdAB4AHwAgACEAIgAjACQAJQAmACcAKAApACoAKwAsAC0ALgAvADAAMQAyADMANAA1ADYANwA4ADkAOgA7ADwAPQA+AD8AQABBAEIAQwBEAEUARgBHAEgASQBKAEsATABNAE4ATwBQAFEAUgBTAFQAVQBWAFcAWABZAFoAWwBcAF0AXgBfAGAAYQAAAAMACAACABAAAf//AAIAAAABAAAAAAABAAAADgAAAAAAAAAAAAIAAQAAAF4AAQABAAAACgBKAGQAAmN5cmwADmxhdG4AGAAEAAAAAP//AAAAEAACSVBBIAAaVklUIAAiAAD//wACAAEAAAAA//8AAQABAAD//wAAAAJrZXJuAA5tYXJrABQAAAABAAEAAAABAAAAAgAGAA4ABAAEAAEAEAACAAAAAQAsAAEADAAQAAAAIAAiAAIAAAABAAYAIQAyADYAQQBSAFYAAAAGAAEAjgAEAAAABgAWADAASgBkAHIAgAAGAA7/nAAhADYAQQA2ADIADQA2//IAUgAXAAYADv+cACEAWABBAFgAMgChADYAvQBSAE8ABgAO/nAAIf6TAEH+kwAy//kANgAOAFL/YQADAA7/nABSABcAVv/VAAMADv+cAFIANgBWAEwAAwAO/nAAUgAJAFYAGQABAAYAIQAyADYAQQBSAFYAAQAAAAoATgBoAAJjeXJsAA5sYXRuABoABAAAAAD//wABAAAAEAACSVBBIAAaVklUIAAiAAD//wACAAAAAQAA//8AAQAAAAD//wABAAAAAmFhbHQADnNtY3AAFAAAAAEAAAAAAAEAAAABAAQAAwAAAAEACAABABgAAwAMABAAFAABAEEAAQBSAAEAVgABAAMAIQAyADYAAA=="

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.ChantDocument = exports.ChantScore = exports.ChantMapping = exports.ChantLineBreak = exports.TextOnly = exports.FaClef = exports.DoClef = exports.Clef = exports.Note = exports.NoteShapeModifiers = exports.NoteShape = exports.LiquescentType = undefined;
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	var _Exsurge2 = __webpack_require__(4);
	
	var _ExsurgeChant = __webpack_require__(7);
	
	var _ExsurgeChant2 = __webpack_require__(8);
	
	var _ExsurgeChant3 = __webpack_require__(9);
	
	var _Exsurge3 = __webpack_require__(10);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var LiquescentType = exports.LiquescentType = {
	  None: 0,
	
	  // flags that can be combined, though of course it
	  // it doesn't make sense to combine some!
	  Large: 1 << 0,
	  Small: 1 << 1,
	  Ascending: 1 << 2,
	  Descending: 1 << 3,
	  InitioDebilis: 1 << 4,
	
	  // handy liquescent types
	  LargeAscending: 1 << 0 | 1 << 2,
	  LargeDescending: 1 << 0 | 1 << 3,
	  SmallAscending: 1 << 1 | 1 << 2,
	  SmallDescending: 1 << 1 | 1 << 3
	};
	
	var NoteShape = exports.NoteShape = {
	  // shapes
	  Default: 0,
	  Virga: 1,
	  Inclinatum: 2,
	  Quilisma: 3,
	  Stropha: 4,
	  Oriscus: 5
	};
	
	var NoteShapeModifiers = exports.NoteShapeModifiers = {
	
	  // flags which modify the shape
	  // not all of them apply to every shape of course
	  None: 0,
	  Ascending: 1 << 0,
	  Descending: 1 << 1,
	  Cavum: 1 << 2,
	  Stemmed: 1 << 3
	};
	
	/**
	 * @class
	 */
	
	var Note = exports.Note = function (_ChantLayoutElement) {
	  _inherits(Note, _ChantLayoutElement);
	
	  /**
	   * @para {Pitch} pitch
	   */
	
	  function Note(pitch) {
	    _classCallCheck(this, Note);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(Note).call(this));
	
	    if (typeof pitch !== 'undefined') _this.pitch = pitch;else _this.pitch = null;
	
	    _this.glyphVisualizer = null;
	
	    // The staffPosition on a note is an integer that indicates the vertical position on the staff.
	    // 0 is the center space on the staff (equivalent to gabc 'g'). Positive numbers go up
	    // the staff, and negative numbers go down, i.e., 1 is gabc 'h', 2 is gabc 'i', -1 is gabc 'f', etc.
	    _this.staffPosition = 0;
	    _this.liquescent = LiquescentType.None;
	    _this.shape = NoteShape.Default;
	    _this.shapeModifiers = NoteShapeModifiers.None;
	
	    // notes keep track of the neume they belong to in order to facilitate layout
	    // this.neume gets set when a note is added to a neume via Neume.addNote()
	    _this.neume = null;
	
	    // various markings that can exist on a note, organized by type
	    // for faster access and simpler code logic
	    _this.epismata = [];
	    _this.morae = []; // silly to have an array of these, but gabc allows multiple morae per note!
	
	    // these are set on the note when they are needed, otherwise, they're undefined
	    // this.ictus
	    // this.accuteAccent
	    // this.braceStart
	    // this.braceEnd
	    return _this;
	  }
	
	  _createClass(Note, [{
	    key: 'setGlyph',
	    value: function setGlyph(ctxt, glyphCode) {
	      if (this.glyphVisualizer) this.glyphVisualizer.setGlyph(ctxt, glyphCode);else this.glyphVisualizer = new _Exsurge2.GlyphVisualizer(ctxt, glyphCode);
	
	      this.glyphVisualizer.setStaffPosition(ctxt, this.staffPosition);
	
	      // assign glyphvisualizer metrics to this note
	      this.bounds.x = this.glyphVisualizer.bounds.x;
	      this.bounds.y = this.glyphVisualizer.bounds.y;
	      this.bounds.width = this.glyphVisualizer.bounds.width;
	      this.bounds.height = this.glyphVisualizer.bounds.height;
	
	      this.origin.x = this.glyphVisualizer.origin.x;
	      this.origin.y = this.glyphVisualizer.origin.y;
	    }
	
	    // a utility function for modifiers
	
	  }, {
	    key: 'shapeModifierMatches',
	    value: function shapeModifierMatches(shapeModifier) {
	      if (shapeModifier === NoteShapeModifiers.None) return this.shapeModifier === NoteShapeModifiers.None;else return this.shapeModifier & shapeModifier !== 0;
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	
	      this.glyphVisualizer.bounds.x = this.bounds.x;
	      this.glyphVisualizer.bounds.y = this.bounds.y;
	
	      this.glyphVisualizer.draw(ctxt);
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      this.glyphVisualizer.bounds.x = this.bounds.x;
	      this.glyphVisualizer.bounds.y = this.bounds.y;
	      return this.glyphVisualizer.createSvgFragment(ctxt);
	    }
	  }]);
	
	  return Note;
	}(_Exsurge2.ChantLayoutElement);
	
	var Clef = exports.Clef = function (_ChantNotationElement) {
	  _inherits(Clef, _ChantNotationElement);
	
	  function Clef(staffPosition, octave) {
	    var defaultAccidental = arguments.length <= 2 || arguments[2] === undefined ? null : arguments[2];
	
	    _classCallCheck(this, Clef);
	
	    var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(Clef).call(this));
	
	    _this2.isClef = true;
	    _this2.staffPosition = staffPosition;
	    _this2.octave = octave;
	    _this2.defaultAccidental = defaultAccidental;
	    _this2.activeAccidental = defaultAccidental;
	    return _this2;
	  }
	
	  _createClass(Clef, [{
	    key: 'resetAccidentals',
	    value: function resetAccidentals() {
	      this.activeAccidental = this.defaultAccidental;
	    }
	  }, {
	    key: 'pitchToStaffPosition',
	    value: function pitchToStaffPosition(pitch) {}
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      ctxt.activeClef = this;
	
	      if (this.defaultAccidental) this.defaultAccidental.performLayout(ctxt);
	
	      _get(Object.getPrototypeOf(Clef.prototype), 'performLayout', this).call(this, ctxt);
	    }
	  }, {
	    key: 'finishLayout',
	    value: function finishLayout(ctxt) {
	
	      // if we have a default accidental, then add a glyph for it now
	      if (this.defaultAccidental) {
	        var accidentalGlyph = this.defaultAccidental.createGlyphVisualizer(ctxt);
	        accidentalGlyph.bounds.x += this.visualizers[0].bounds.right() + ctxt.intraNeumeSpacing;
	        this.addVisualizer(accidentalGlyph);
	      }
	
	      _get(Object.getPrototypeOf(Clef.prototype), 'finishLayout', this).call(this, ctxt);
	    }
	  }], [{
	    key: 'default',
	    value: function _default() {
	      return __defaultDoClef;
	    }
	  }]);
	
	  return Clef;
	}(_Exsurge2.ChantNotationElement);
	
	var DoClef = exports.DoClef = function (_Clef) {
	  _inherits(DoClef, _Clef);
	
	  function DoClef(staffPosition, octave) {
	    var defaultAccidental = arguments.length <= 2 || arguments[2] === undefined ? null : arguments[2];
	
	    _classCallCheck(this, DoClef);
	
	    var _this3 = _possibleConstructorReturn(this, Object.getPrototypeOf(DoClef).call(this, staffPosition, octave, defaultAccidental));
	
	    _this3.leadingSpace = 0.0;
	    return _this3;
	  }
	
	  _createClass(DoClef, [{
	    key: 'pitchToStaffPosition',
	    value: function pitchToStaffPosition(pitch) {
	      return (pitch.octave - this.octave) * 7 + this.staffPosition + _Exsurge.Pitch.stepToStaffOffset(pitch.step) - _Exsurge.Pitch.stepToStaffOffset(_Exsurge.Step.Do);
	    }
	  }, {
	    key: 'staffPositionToPitch',
	    value: function staffPositionToPitch(staffPosition) {
	      var offset = staffPosition - this.staffPosition;
	      var octaveOffset = Math.floor(offset / 7);
	
	      var step = _Exsurge.Pitch.staffOffsetToStep(offset);
	
	      if (this.defaultAccidental !== null && step === this.defaultAccidental.step) step += this.defaultAccidental.accidentalType;
	
	      return new _Exsurge.Pitch(step, this.octave + octaveOffset);
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(DoClef.prototype), 'performLayout', this).call(this, ctxt);
	
	      var glyph = new _Exsurge2.GlyphVisualizer(ctxt, _Exsurge2.GlyphCode.DoClef);
	      glyph.setStaffPosition(ctxt, this.staffPosition);
	      this.addVisualizer(glyph);
	
	      this.finishLayout(ctxt);
	    }
	  }, {
	    key: 'clone',
	    value: function clone() {
	      return new DoClef(this.staffPosition, this.octave, this.defaultAccidental);
	    }
	  }]);
	
	  return DoClef;
	}(Clef);
	
	var __defaultDoClef = new DoClef(1, 2);
	
	var FaClef = exports.FaClef = function (_Clef2) {
	  _inherits(FaClef, _Clef2);
	
	  function FaClef(staffPosition, octave) {
	    var defaultAccidental = arguments.length <= 2 || arguments[2] === undefined ? null : arguments[2];
	
	    _classCallCheck(this, FaClef);
	
	    var _this4 = _possibleConstructorReturn(this, Object.getPrototypeOf(FaClef).call(this, staffPosition, octave, defaultAccidental));
	
	    _this4.octave = octave;
	
	    _this4.leadingSpace = 0;
	    return _this4;
	  }
	
	  _createClass(FaClef, [{
	    key: 'pitchToStaffPosition',
	    value: function pitchToStaffPosition(pitch) {
	      return (pitch.octave - this.octave) * 7 + this.staffPosition + _Exsurge.Pitch.stepToStaffOffset(pitch.step) - _Exsurge.Pitch.stepToStaffOffset(_Exsurge.Step.Fa);
	    }
	  }, {
	    key: 'staffPositionToPitch',
	    value: function staffPositionToPitch(staffPosition) {
	      var offset = staffPosition - this.staffPosition + 3; // + 3 because it's a fa clef (3 == offset from Do)
	      var octaveOffset = Math.floor(offset / 7);
	
	      var step = _Exsurge.Pitch.staffOffsetToStep(offset);
	
	      if (step === _Exsurge.Step.Ti && this.defaultAccidental === _ExsurgeChant2.AccidentalType.Flat) step = _Exsurge.Step.Te;
	
	      return new _Exsurge.Pitch(step, this.octave + octaveOffset);
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(FaClef.prototype), 'performLayout', this).call(this, ctxt);
	
	      var glyph = new _Exsurge2.GlyphVisualizer(ctxt, _Exsurge2.GlyphCode.FaClef);
	      glyph.setStaffPosition(ctxt, this.staffPosition);
	      this.addVisualizer(glyph);
	
	      this.finishLayout(ctxt);
	    }
	  }, {
	    key: 'clone',
	    value: function clone() {
	      return new FaClef(this.staffPosition, this.octave, this.defaultAccidental);
	    }
	  }]);
	
	  return FaClef;
	}(Clef);
	
	/*
	 * TextOnly
	 */
	
	
	var TextOnly = exports.TextOnly = function (_ChantNotationElement2) {
	  _inherits(TextOnly, _ChantNotationElement2);
	
	  function TextOnly() {
	    _classCallCheck(this, TextOnly);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(TextOnly).call(this));
	  }
	
	  _createClass(TextOnly, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(TextOnly.prototype), 'performLayout', this).call(this, ctxt);
	
	      // add an empty glyph as a placeholder
	      this.addVisualizer(new _Exsurge2.GlyphVisualizer(ctxt, _Exsurge2.GlyphCode.None));
	
	      this.origin.x = 0;
	      this.origin.y = 0;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return TextOnly;
	}(_Exsurge2.ChantNotationElement);
	
	var ChantLineBreak = exports.ChantLineBreak = function (_ChantNotationElement3) {
	  _inherits(ChantLineBreak, _ChantNotationElement3);
	
	  function ChantLineBreak(justify) {
	    _classCallCheck(this, ChantLineBreak);
	
	    var _this6 = _possibleConstructorReturn(this, Object.getPrototypeOf(ChantLineBreak).call(this));
	
	    _this6.justify = justify;
	    return _this6;
	  }
	
	  _createClass(ChantLineBreak, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      // reset the bounds before doing a layout
	      this.bounds = new _Exsurge.Rect(0, 0, 0, 0);
	    }
	  }, {
	    key: 'clone',
	    value: function clone() {
	      var lb = new ChantLineBreak();
	      lb.justify = this.justify;
	
	      return lb;
	    }
	  }]);
	
	  return ChantLineBreak;
	}(_Exsurge2.ChantNotationElement);
	
	// a chant mapping is a lightweight format independent way of
	// tracking how a chant language (e.g., gabc) has been
	// mapped to exsurge notations.
	
	
	var ChantMapping =
	
	// source can be any object type. in the case of gabc, source is a text
	// string that maps to a gabc word (e.g.: "no(g)bis(fg)").
	// notations is an array of ChantNotationElements
	exports.ChantMapping = function ChantMapping(source, notations) {
	  _classCallCheck(this, ChantMapping);
	
	  this.source = source;
	  this.notations = notations;
	};
	
	/*
	 * Score, document
	 */
	
	
	var ChantScore = exports.ChantScore = function () {
	
	  // mappings is an array of ChantMappings.
	
	  function ChantScore(ctxt) {
	    var mappings = arguments.length <= 1 || arguments[1] === undefined ? [] : arguments[1];
	    var useDropCap = arguments[2];
	
	    _classCallCheck(this, ChantScore);
	
	    this.mappings = mappings;
	
	    this.lines = [];
	    this.notes = [];
	
	    this.startingClef = null;
	
	    this.useDropCap = useDropCap;
	    this.dropCap = null;
	
	    this.annotation = null;
	
	    this.compiled = false;
	
	    this.autoColoring = true;
	    this.needsLayout = true;
	
	    // valid after chant lines are created...
	    this.bounds = new _Exsurge.Rect();
	
	    this.updateNotations(ctxt);
	  }
	
	  _createClass(ChantScore, [{
	    key: 'updateNotations',
	    value: function updateNotations(ctxt) {
	
	      var i;
	
	      // flatten all mappings into one array for N(0) access to notations
	      this.notations = [];
	      for (i = 0; i < this.mappings.length; i++) {
	        this.notations = this.notations.concat(this.mappings[i].notations);
	      } // find the starting clef...
	      // start with a default clef in case the notations don't provide one.
	      this.startingClef = null;
	      var defaultClef = new DoClef(1, 2);
	
	      for (i = 0; i < this.notations.length; i++) {
	
	        // if there are neumes before the clef, then we just keep the default clef above
	        if (this.notations[i].isNeume) {
	          this.startingClef = defaultClef;
	          break;
	        }
	
	        // otherwise, if we find a clef, before neumes then we use that as our default
	        if (this.notations[i].isClef) {
	          this.startingClef = this.notations[i];
	
	          // the clef is taken out of the notations...
	          this.notations.splice(i, 1); // remove a single notation
	
	          break;
	        }
	      }
	
	      // if we've reached this far and we *still* don't have a clef, then there aren't even
	      // any neumes in the score. still, set the default clef just for good measure
	      if (!this.startingClef) this.startingClef = defaultClef;
	
	      // update drop cap
	      if (this.useDropCap) this.recreateDropCap(ctxt);
	
	      this.needsLayout = true;
	    }
	  }, {
	    key: 'recreateDropCap',
	    value: function recreateDropCap(ctxt) {
	
	      // find the first notation with lyrics to use
	      for (var i = 0; i < this.notations.length; i++) {
	        if (this.notations[i].hasLyrics() && this.notations[i].lyrics[0] !== null) {
	          this.dropCap = this.notations[i].lyrics[0].generateDropCap(ctxt);
	          return;
	        }
	      }
	    }
	
	    // this is the the synchronous version of performLayout that
	    // process everything without yielding to any other workers/threads.
	    // good for server side processing or very small chant pieces.
	
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      if (this.needsLayout === false) return; // nothing to do here!
	
	      // setup the context
	      ctxt.activeClef = this.startingClef;
	      ctxt.notations = this.notations;
	      ctxt.currNotationIndex = 0;
	
	      if (this.dropCap) this.dropCap.recalculateMetrics(ctxt);
	
	      if (this.annotation) this.annotation.recalculateMetrics(ctxt);
	
	      for (var i = 0; i < this.notations.length; i++) {
	        this.notations[i].performLayout(ctxt);
	        ctxt.currNotationIndex++;
	      }
	
	      this.needsLayout = false;
	    }
	
	    // for web applications, probably performLayoutAsync would be more
	    // apppropriate that the above performLayout, since it will process
	    // the notations without locking up the UI thread.
	
	  }, {
	    key: 'performLayoutAsync',
	    value: function performLayoutAsync(ctxt, finishedCallback) {
	      var _this7 = this;
	
	      if (this.needsLayout === false) {
	        if (finishedCallback) setTimeout(function () {
	          return finishedCallback();
	        }, 0);
	
	        return; // nothing to do here!
	      }
	
	      // setup the context
	      ctxt.activeClef = this.startingClef;
	      ctxt.notations = this.notations;
	      ctxt.currNotationIndex = 0;
	
	      if (this.dropCap) this.dropCap.recalculateMetrics(ctxt);
	
	      if (this.annotation) this.annotation.recalculateMetrics(ctxt);
	
	      setTimeout(function () {
	        return _this7.layoutElementsAsync(ctxt, 0, finishedCallback);
	      }, 0);
	    }
	  }, {
	    key: 'layoutElementsAsync',
	    value: function layoutElementsAsync(ctxt, index, finishedCallback) {
	      var _this8 = this;
	
	      if (index >= this.notations.length) {
	        this.needsLayout = false;
	
	        if (finishedCallback) setTimeout(function () {
	          return finishedCallback();
	        }, 0);
	
	        return;
	      }
	
	      if (index === 0) ctxt.activeClef = this.startingClef;
	
	      var timeout = new Date().getTime() + 50; // process for fifty milliseconds
	      do {
	        var notation = this.notations[index];
	        if (notation.needsLayout) {
	          ctxt.currNotationIndex = index;
	          notation.performLayout(ctxt);
	        }
	
	        index++;
	      } while (index < this.notations.length && new Date().getTime() < timeout);
	
	      // schedule the next block of processing
	      setTimeout(function () {
	        return _this8.layoutElementsAsync(ctxt, index, finishedCallback);
	      }, 0);
	    }
	  }, {
	    key: 'layoutChantLines',
	    value: function layoutChantLines(ctxt, width, finishedCallback) {
	
	      this.lines = [];
	
	      var y = 0;
	      var currIndex = 0;
	
	      ctxt.activeClef = this.startingClef;
	
	      do {
	
	        var line = new _ExsurgeChant.ChantLine(this);
	
	        line.buildFromChantNotationIndex(ctxt, currIndex, width);
	        currIndex = line.notationsStartIndex + line.numNotationsOnLine;
	        line.performLayout(ctxt);
	        this.lines.push(line);
	
	        line.bounds.y = -line.bounds.y + y;
	        y += line.bounds.height + ctxt.staffInterval * 1.5;
	      } while (currIndex < this.notations.length);
	
	      var lastLine = this.lines[this.lines.length - 1];
	
	      this.bounds.x = 0;
	      this.bounds.y = 0;
	      this.bounds.width = lastLine.bounds.width;
	      this.bounds.height = y;
	
	      if (finishedCallback) finishedCallback(this);
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      canvasCtxt.clearRect(0, 0, ctxt.canvas.width, ctxt.canvas.height);
	
	      canvasCtxt.translate(this.bounds.x, this.bounds.y);
	
	      for (var i = 0; i < this.lines.length; i++) {
	        this.lines[i].draw(ctxt);
	      }canvasCtxt.translate(-this.bounds.x, -this.bounds.y);
	    }
	  }, {
	    key: 'createSvg',
	    value: function createSvg(ctxt) {
	
	      var fragment = "";
	
	      // create defs section
	      for (var def in ctxt.defs) {
	        if (ctxt.defs.hasOwnProperty(def)) fragment += ctxt.defs[def];
	      }fragment = _Exsurge2.QuickSvg.createFragment('defs', {}, fragment);
	
	      for (var i = 0; i < this.lines.length; i++) {
	        fragment += this.lines[i].createSvgFragment(ctxt);
	      }fragment = _Exsurge2.QuickSvg.createFragment('g', {}, fragment);
	
	      fragment = _Exsurge2.QuickSvg.createFragment('svg', {
	        'xmlns': 'http://www.w3.org/2000/svg',
	        'version': '1.1',
	        'xmlns:xlink': 'http://www.w3.org/1999/xlink',
	        'class': 'ChantScore',
	        'width': this.bounds.width,
	        'height': this.bounds.height
	      }, fragment);
	
	      return fragment;
	    }
	  }, {
	    key: 'unserializeFromJson',
	    value: function unserializeFromJson(data) {
	      this.autoColoring = data['auto-coloring'];
	
	      if (data.annotation !== null && data.annotation !== "") {
	        // create the annotation
	        this.annotation = new _Exsurge2.Annotation(ctxt, data.annotation);
	      } else this.annotation = null;
	
	      var createDropCap = data['drop-cap'] === 'auto' ? true : false;
	
	      _Exsurge3.Gabc.parseChantNotations(data.notations, this, createDropCap);
	    }
	  }, {
	    key: 'serializeToJson',
	    value: function serializeToJson() {
	      var data = {};
	
	      data['type'] = "score";
	      data['auto-coloring'] = true;
	
	      if (this.annotation !== null) data.annotation = this.annotation.unsanitizedText;else data.annotation = "";
	
	      return data;
	    }
	  }]);
	
	  return ChantScore;
	}();
	
	var ChantDocument = exports.ChantDocument = function () {
	  function ChantDocument() {
	    _classCallCheck(this, ChantDocument);
	
	    var defaults = {
	      layout: {
	        units: "mm",
	        'default-font': {
	          'font-family': "Crimson",
	          'font-size': 14
	        },
	        page: {
	          width: 8.5,
	          height: 11,
	          'margin-left': 0,
	          'margin-top': 0,
	          'margin-right': 0,
	          'margin-bottom': 0
	        }
	      },
	      scores: []
	    };
	
	    // default layout
	    this.copyLayout(this, defaults);
	
	    this.scores = defaults.scores;
	  }
	
	  _createClass(ChantDocument, [{
	    key: 'copyLayout',
	    value: function copyLayout(to, from) {
	
	      to.layout = {
	        units: from.layout.units,
	        'default-font': {
	          'font-family': from.layout['default-font']['font-family'],
	          'font-size': from.layout['default-font']['font-size']
	        },
	        page: {
	          width: from.layout.page.width,
	          height: from.layout.page.height,
	          'margin-left': from.layout.page['margin-left'],
	          'margin-top': from.layout.page['margin-top'],
	          'margin-right': from.layout.page['margin-right'],
	          'margin-bottom': from.layout.page['margin-bottom']
	        }
	      };
	    }
	  }, {
	    key: 'unserializeFromJson',
	    value: function unserializeFromJson(data) {
	
	      this.copyLayout(this, data);
	
	      this.scores = [];
	
	      // read in the scores
	      for (var i = 0; i < data.scores.length; i++) {
	        var score = new ChantScore();
	
	        score.unserializeFromJson(data.scores[i]);
	        this.scores.push(score);
	      }
	    }
	  }, {
	    key: 'serializeToJson',
	    value: function serializeToJson() {
	      var data = {};
	
	      this.copyLayout(data, this);
	
	      data.scores = [];
	
	      // save scores...
	      for (var i = 0; i < this.scores.length; i++) {
	        data.scores.push(this.scores[i].serializeToJson());
	      }return data;
	    }
	  }]);
	
	  return ChantDocument;
	}();

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.ChantLine = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	var _Exsurge2 = __webpack_require__(4);
	
	var _Exsurge3 = __webpack_require__(6);
	
	var _Exsurge4 = __webpack_require__(3);
	
	var _ExsurgeChant = __webpack_require__(8);
	
	var _ExsurgeChant2 = __webpack_require__(9);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	// a chant line represents one staff line on the page. ChantLines are created by the score
	// and laid out by the page
	
	var ChantLine = exports.ChantLine = function (_ChantLayoutElement) {
	  _inherits(ChantLine, _ChantLayoutElement);
	
	  function ChantLine(score) {
	    _classCallCheck(this, ChantLine);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(ChantLine).call(this));
	
	    _this.score = score;
	
	    _this.notationsStartIndex = 0;
	    _this.numNotationsOnLine = 0;
	    _this.notationBounds = null; // Rect
	
	    _this.staffLeft = 0;
	    _this.staffRight = 0;
	
	    _this.startingClef = null; // necessary for the layout process
	    _this.custos = null;
	
	    _this.justify = true;
	
	    // these are markings that exist at the chant line level rather than at the neume level.
	    _this.ledgerLines = [];
	    _this.braces = [];
	
	    _this.nextLine = null;
	    _this.previousLine = null; // for layout assistance
	
	    _this.lyricLineHeights = []; // height of each text line
	    _this.lyricLineBaselines = []; // offsets from the top of the text line to the baseline
	
	    // fixme: make these configurable values from the score
	    _this.spaceAfterNotations = 0; // the space between the notation bounds and the first text track
	    _this.spaceBetweenTextTracks = 0; // spacing between each text track
	    return _this;
	  }
	
	  _createClass(ChantLine, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      // start off with a rectangle that holds at least the four staff lines
	      // we fudge the 3 to 3.1 so that the svg doesn't crop off the upper/lower staff lines...
	      this.notationBounds = new _Exsurge.Rect(this.staffLeft, -3.1 * ctxt.staffInterval, this.staffRight - this.staffLeft, 6.2 * ctxt.staffInterval);
	
	      // run through all the elements of the line and calculate the bounds of the notations,
	      // as well as the bounds of each text track we will use
	      var i;
	      var notations = this.score.notations;
	      var lastIndex = this.notationsStartIndex + this.numNotationsOnLine;
	      var notation = null;
	
	      this.notationBounds.union(this.startingClef.bounds);
	
	      // reset the lyric line offsets before we [re]calculate them now
	      this.lyricLineHeights = [];
	      this.lyricLineBaselines = [];
	
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	        notation = notations[i];
	
	        this.notationBounds.union(notation.bounds);
	
	        // keep track of lyric line offsets
	        for (j = 0; j < notation.lyrics.length; j++) {
	          if (this.lyricLineHeights.length < j + 1) {
	            this.lyricLineHeights.push(0);
	            this.lyricLineBaselines.push(0);
	          }
	
	          this.lyricLineHeights[j] = Math.max(this.lyricLineHeights[j], notation.lyrics[j].bounds.height);
	          this.lyricLineBaselines[j] = Math.max(this.lyricLineBaselines[j], notation.lyrics[j].origin.y);
	        }
	      }
	
	      if (this.custos) this.notationBounds.union(this.custos.bounds);
	
	      // finalize the lyrics placement
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	        notation = notations[i];
	
	        var offset = this.notationBounds.y + this.notationBounds.height;
	
	        for (var j = 0; j < notation.lyrics.length; j++) {
	          notation.lyrics[j].bounds.y = offset + this.lyricLineBaselines[j];
	          offset += this.lyricLineHeights[j];
	        }
	      }
	
	      // add any braces to the notationBounds as well
	      for (i = 0; i < this.braces.length; i++) {
	        this.notationBounds.union(this.braces[i].bounds);
	      }var totalHeight = this.notationBounds.height;
	
	      // add up the lyric line heights to get the total height of the chant line
	      for (i = 0; i < this.lyricLineHeights.length; i++) {
	        totalHeight += this.lyricLineHeights[i];
	      } // dropCap and the annotations
	      if (this.notationsStartIndex === 0) {
	
	        if (this.score.dropCap !== null) {
	
	          var dropCapY;
	          if (this.lyricLineHeights.length > 0) {
	            dropCapY = this.notationBounds.y + this.notationBounds.height + this.lyricLineBaselines[0];
	          } else dropCapY = this.notationBounds.y + this.notationBounds.height;
	
	          // drop caps and annotations are drawn from their center, so aligning them
	          // horizontally is as easy as this.staffLeft / 2
	          this.score.dropCap.bounds.x = this.staffLeft / 2;
	          this.score.dropCap.bounds.y = dropCapY;
	        }
	
	        if (this.score.annotation !== null) {
	          // annotations use dominant-baseline to align text to the top
	          this.score.annotation.bounds.x = this.staffLeft / 2;
	          this.score.annotation.bounds.y = -ctxt.staffInterval * 3;
	        }
	      }
	
	      this.notationBounds.height += ctxt.lyricTextSize;
	
	      this.bounds.x = 0;
	      this.bounds.y = this.notationBounds.y;
	      this.bounds.width = this.notationBounds.right();
	      this.bounds.height = totalHeight;
	
	      // the origin of the chant line's coordinate space is at the center line of the left extremity of the staff
	      this.origin = new _Exsurge.Point(this.staffLeft, -this.notationBounds.y);
	    }
	  }, {
	    key: 'draw',
	    value: function draw(ctxt) {
	
	      var canvasCtxt = ctxt.canvasCtxt;
	
	      canvasCtxt.translate(this.bounds.x, this.bounds.y);
	
	      // draw the chant lines
	      var i,
	          x1 = this.staffLeft,
	          x2 = this.staffRight,
	          y;
	
	      canvasCtxt.lineWidth = Math.round(ctxt.staffLineWeight);
	      canvasCtxt.strokeStyle = ctxt.staffLineWeight;
	
	      for (i = -3; i <= 3; i += 2) {
	
	        y = Math.round(ctxt.staffInterval * i) + 0.5;
	
	        canvasCtxt.beginPath();
	        canvasCtxt.moveTo(x1, y);
	        canvasCtxt.lineTo(x2, y);
	        canvasCtxt.stroke();
	      }
	
	      // draw the ledger lines
	      for (i = 0; i < this.ledgerLines.length; i++) {
	
	        var ledgerLine = this.ledgerLines[i];
	        y = ctxt.calculateHeightFromStaffPosition(ledgerLine.staffPosition);
	
	        canvasCtxt.beginPath();
	        canvasCtxt.moveTo(ledgerLine.x1, y);
	        canvasCtxt.lineTo(ledgerLine.x2, y);
	        canvasCtxt.stroke();
	      }
	
	      // fixme: draw the braces
	
	      // draw the dropCap and the annotations
	      if (this.notationsStartIndex === 0) {
	
	        if (this.score.dropCap !== null) this.score.dropCap.draw(ctxt);
	
	        if (this.score.annotation !== null) this.score.annotation.draw(ctxt);
	      }
	
	      // draw the notations
	      var notations = this.score.notations;
	      var lastIndex = this.notationsStartIndex + this.numNotationsOnLine;
	
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	        notations[i].draw(ctxt);
	      }this.startingClef.draw(ctxt);
	
	      if (this.custos) this.custos.draw(ctxt);
	
	      canvasCtxt.translate(-this.bounds.x, -this.bounds.y);
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	      var inner = "";
	
	      // add the chant lines
	      var i,
	          x1 = this.staffLeft,
	          x2 = this.staffRight;
	
	      // create the staff lines
	      for (i = -3; i <= 3; i += 2) {
	
	        inner += _Exsurge2.QuickSvg.createFragment('line', {
	          'x1': x1,
	          'y1': ctxt.staffInterval * i,
	          'x2': x2,
	          'y2': ctxt.staffInterval * i,
	          'stroke': ctxt.staffLineColor,
	          'stroke-width': ctxt.staffLineWeight,
	          'class': 'staffLine'
	        });
	      }
	
	      // create the ledger lines
	      for (i = 0; i < this.ledgerLines.length; i++) {
	
	        var ledgerLine = this.ledgerLines[i];
	        var y = ctxt.calculateHeightFromStaffPosition(ledgerLine.staffPosition);
	
	        inner += _Exsurge2.QuickSvg.createFragment('line', {
	          'x1': ledgerLine.x1,
	          'y1': y,
	          'x2': ledgerLine.x2,
	          'y2': y,
	          'stroke': ctxt.staffLineColor,
	          'stroke-width': ctxt.staffLineWeight,
	          'class': 'ledgerLine'
	        });
	      }
	
	      // add any braces
	      for (i = 0; i < this.braces.length; i++) {
	        inner += this.braces[i].createSvgFragment(ctxt);
	      } // dropCap and the annotations
	      if (this.notationsStartIndex === 0) {
	
	        if (this.score.dropCap !== null) inner += this.score.dropCap.createSvgFragment(ctxt);
	
	        if (this.score.annotation !== null) inner += this.score.annotation.createSvgFragment(ctxt);
	      }
	
	      inner += this.startingClef.createSvgFragment(ctxt);
	
	      var notations = this.score.notations;
	      var lastIndex = this.notationsStartIndex + this.numNotationsOnLine;
	
	      // add all of the notations
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	        inner += notations[i].createSvgFragment(ctxt);
	      }if (this.custos) inner += this.custos.createSvgFragment(ctxt);
	
	      return _Exsurge2.QuickSvg.createFragment('g', {
	        'class': 'chantLine',
	        'transform': 'translate(' + this.bounds.x + ',' + this.bounds.y + ')'
	      }, inner);
	    }
	
	    // code below based on code by: https://gist.github.com/alexhornbake
	    //
	    // optimized for braces that are only drawn horizontally.
	    // returns svg path string ready to insert into svg doc
	
	  }, {
	    key: 'generateCurlyBraceDrawable',
	    value: function generateCurlyBraceDrawable(ctxt, x1, x2, y, isAbove) {
	
	      var h;
	
	      if (isAbove) h = -ctxt.staffInterval / 2;else h = ctxt.staffInterval / 2;
	
	      // and q factor, .5 is normal, higher q = more expressive bracket
	      var q = 0.6;
	
	      var dx = -1;
	      var len = x2 - x1;
	
	      //Calculate Control Points of path,
	      var qx1 = x1;
	      var qy1 = y + q * h;
	      var qx2 = x1 + .25 * len;
	      var qy2 = y + (1 - q) * h;
	      var tx1 = x1 + .5 * len;
	      var ty1 = y + h;
	      var qx3 = x2;
	      var qy3 = y + q * h;
	      var qx4 = x1 + .75 * len;
	      var qy4 = y + (1 - q) * h;
	      var d = "M " + x1 + " " + y + " Q " + qx1 + " " + qy1 + " " + qx2 + " " + qy2 + " T " + tx1 + " " + ty1 + " M " + x2 + " " + y + " Q " + qx3 + " " + qy3 + " " + qx4 + " " + qy4 + " T " + tx1 + " " + ty1;
	
	      return _Exsurge2.QuickSvg.createFragment('path', {
	        'd': d,
	        'stroke': ctxt.neumeLineColor,
	        'stroke-width': ctxt.neumeLineWeight + 'px',
	        'fill': 'none'
	      });
	    }
	  }, {
	    key: 'buildFromChantNotationIndex',
	    value: function buildFromChantNotationIndex(ctxt, newElementStart, width) {
	
	      // todo: reset / clear the children we have in case they have data
	      var notations = this.score.notations;
	      this.notationsStartIndex = newElementStart;
	      this.numNotationsOnLine = 0;
	
	      this.staffLeft = 0;
	
	      if (width > 0) this.staffRight = width;else this.staffRight = 99999999; // no limit to staff size
	
	      // If this is the first chant line, then we have to make room for a
	      // drop cap and/or annotation, if present
	      if (this.notationsStartIndex === 0) {
	
	        var padding = 0;
	
	        if (this.score.dropCap !== null) padding = this.score.dropCap.bounds.width + this.score.dropCap.padding * 2;
	
	        if (this.score.annotation !== null) padding = Math.max(padding, this.score.annotation.bounds.width + this.score.annotation.padding * 4);
	
	        this.staffLeft += padding;
	      }
	
	      // set up the clef...
	      // if the first notation on the line is a starting clef, then we treat it a little differently...
	      // the clef becomes this line's starting clef and we skip over the clef in the notations array
	      if (notations[newElementStart].isClef) {
	        ctxt.activeClef = notations[newElementStart].clone();
	        newElementStart++;
	        this.notationsStartIndex++;
	      }
	
	      // make a copy for this line to use at the beginning
	      this.startingClef = ctxt.activeClef.clone();
	      this.startingClef.performLayout(ctxt);
	      this.startingClef.bounds.x = this.staffLeft;
	
	      var curr = this.startingClef,
	          prev = null,
	          prevWithLyrics = null;
	
	      // estimate how much space we have available to us
	      var rightNotationBoundary = this.staffRight - _Exsurge4.Glyphs.CustosLong.bounds.width * ctxt.glyphScaling - ctxt.intraNeumeSpacing * 4; // possible custos on the line
	
	      // iterate through the notations, fittng what we can on this line
	      var i,
	          j,
	          lastNotationIndex = notations.length - 1;
	
	      for (i = newElementStart; i <= lastNotationIndex; i++) {
	
	        if (curr.hasLyrics()) prevWithLyrics = curr;
	
	        prev = curr;
	        curr = notations[i];
	
	        var actualRightBoundary;
	        if (i === lastNotationIndex) {
	          // on the last notation of the score, we don't need a custos or trailing space, so we use staffRight as the
	          // right boundary.
	          actualRightBoundary = this.staffRight;
	        } else if (i === lastNotationIndex - 1) {
	          // on the penultimate notation, make sure there is at least enough room for whichever takes up less space,
	          // between the final notation and a custos:
	          actualRightBoundary = Math.max(rightNotationBoundary, this.staffRight - notations[lastNotationIndex].bounds.width);
	        } else {
	          // Otherwise, we use rightNotationBoundary, which leaves room for a custos...
	          actualRightBoundary = rightNotationBoundary;
	        }
	
	        // try to fit the curr element on this line.
	        // if it doesn't fit, we finish up here.
	        var fitsOnLine = this.positionNotationElement(ctxt, prevWithLyrics, prev, curr, actualRightBoundary);
	        if (fitsOnLine === false) {
	
	          // check for an end brace in the curr element
	          var braceEndIndex = curr.notes && curr.notes.reduce(function (result, n, i) {
	            return result || n.braceEnd && i + 1 || 0;
	          }, 0);
	          var braceStartIndex = curr.notes && curr.notes.reduce(function (result, n, i) {
	            return result || n.braceStart && i + 1 || 0;
	          }, 0);
	          // if there is not a start brace earlier in the element than the end brace, we need to find the earlier start brace
	          // to keep the entire brace together on the next line
	          if (braceEndIndex && (!braceStartIndex || braceStartIndex > braceEndIndex)) {
	            // find last index of start brace
	            var index = notations.slice(this.notationsStartIndex, i).reduceRight(function (accum, cne, index) {
	              if (accum === -1 && cne.notes) {
	                var braceStart = cne.notes.filter(function (n) {
	                  return n.braceStart;
	                }).length;
	                var braceEnd = cne.notes.filter(function (n) {
	                  return n.braceEnd;
	                }).length;
	                // if we see another end brace before we get to a start brace, short circuit
	                if (braceEnd) return -2;
	                if (braceStart) return index;
	              }
	              return accum;
	            }, -1);
	            // if the start brace was found, this line needs to end just before it:
	            if (index > 0) {
	              this.numNotationsOnLine = index;
	              i = index + this.notationsStartIndex;
	            }
	          }
	
	          // check if the prev elements want to be kept with this one
	          for (j = i - 1; j > this.notationsStartIndex; j--) {
	            var cne = notations[j];
	
	            if (cne.keepWithNext === true || j === i - 1 && curr.isDivider) this.numNotationsOnLine--;else break;
	          }
	
	          // we are at the end of the line!
	          break;
	        }
	
	        curr.chantLine = this;
	        this.numNotationsOnLine++;
	
	        if (curr.isClef) ctxt.activeClef = curr;
	
	        // line breaks are a special case indicating to stop processing here
	        if (curr.constructor === _Exsurge3.ChantLineBreak && width > 0) {
	          this.justify = curr.justify;
	          break;
	        }
	      }
	
	      // create the automatic custos at the end of the line if there are neumes left in the notations
	      for (i = this.notationsStartIndex + this.numNotationsOnLine; i < notations.length; i++) {
	        var notation = notations[i];
	
	        if (notation.isNeume) {
	
	          this.custos = new _ExsurgeChant.Custos(true);
	          ctxt.currNotationIndex = i - 1; // make sure the context knows where the custos is
	          this.custos.performLayout(ctxt);
	
	          // Put the custos at the very end of the line
	          this.custos.bounds.x = this.staffRight - this.custos.bounds.width - this.custos.leadingSpace;
	
	          // nothing more to see here...
	          break;
	        }
	      }
	
	      // if the provided width is less than zero, then set the width of the line
	      // based on the last notation
	      var last = notations[this.notationsStartIndex + this.numNotationsOnLine - 1];
	      if (width <= 0) {
	        this.staffRight = last.bounds.right();
	        this.justify = false;
	      } else if (this.notationsStartIndex + this.numNotationsOnLine === notations.length) {
	        // this is the last chant line.
	        this.justify = true;
	        this.justify = last.isDivider && (this.staffRight - last.bounds.right()) / this.staffRight < .1;
	      }
	
	      // Justify the line if we need to
	      if (this.justify === true) this.justifyElements();
	
	      this.finishLayout(ctxt);
	    }
	  }, {
	    key: 'justifyElements',
	    value: function justifyElements() {
	
	      var i;
	      var toJustify = [];
	      var notations = this.score.notations;
	      var lastIndex = this.notationsStartIndex + this.numNotationsOnLine;
	
	      // first step of justification is to determine how much space we have to use up
	      var extraSpace = 0;
	
	      if (this.numNotationsOnLine > 0) {
	        var last = notations[lastIndex - 1],
	            lastWithLyrics = null;
	
	        for (i = lastIndex - 1; i >= this.notationsStartIndex; i--) {
	          if (notations[i].hasLyrics()) {
	            lastWithLyrics = notations[i];
	            break;
	          }
	        }
	
	        if (lastWithLyrics) extraSpace = this.staffRight - Math.max(lastWithLyrics.getAllLyricsRight(), last.bounds.right() + last.trailingSpace);else extraSpace = this.staffRight - (last.bounds.right() + last.trailingSpace);
	      }
	
	      if (this.custos) extraSpace -= this.custos.bounds.width + this.custos.leadingSpace;
	
	      if (extraSpace <= 0) return;
	
	      var prev = null,
	          curr = null,
	          prevWithLyrics = null;
	
	      // first pass: determine the neumes we can space apart
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	
	        if (curr !== null && curr.hasLyrics()) prevWithLyrics = curr;
	
	        prev = curr;
	        curr = notations[i];
	
	        if (prev !== null && prev.keepWithNext === true) continue;
	
	        if (prevWithLyrics !== null && prevWithLyrics.lyrics[0].allowsConnector() && !prevWithLyrics.lyrics[0].needsConnector) continue;
	
	        if (curr.constructor === _Exsurge3.ChantLineBreak) continue;
	
	        // otherwise, we can add space before this element
	        toJustify.push(curr);
	      }
	
	      if (toJustify.length === 0) return;
	
	      var offset = 0;
	      var increment = extraSpace / toJustify.length;
	      var toJustifyIndex = 0;
	      for (i = this.notationsStartIndex; i < lastIndex; i++) {
	
	        curr = notations[i];
	
	        if (toJustifyIndex < toJustify.length && toJustify[toJustifyIndex] === curr) {
	          offset += increment;
	          toJustifyIndex++;
	        }
	
	        curr.bounds.x += offset;
	      }
	    }
	  }, {
	    key: 'finishLayout',
	    value: function finishLayout(ctxt) {
	      var _this2 = this;
	
	      this.ledgerLines = []; // clear any existing ledger lines
	
	      var notations = this.score.notations;
	      var lastIndex = this.notationsStartIndex + this.numNotationsOnLine;
	
	      // an element needs to have a staffPosition property, as well as the standard
	      // bounds property. so it could be a note, or it could be a custos
	      // offsetX and offsetY can be used to add to the position info for the element,
	      // useful in the case of notes.
	      var processElementForLedgerLine = function processElementForLedgerLine(element) {
	        var offsetX = arguments.length <= 1 || arguments[1] === undefined ? 0 : arguments[1];
	        var offsetY = arguments.length <= 2 || arguments[2] === undefined ? 0 : arguments[2];
	
	
	        // do we need a ledger line for this note?
	        var staffPosition = element.staffPosition;
	
	        if (staffPosition >= 5 || staffPosition <= -5) {
	
	          var x1 = offsetX + element.bounds.x - ctxt.intraNeumeSpacing;
	          var x2 = offsetX + element.bounds.x + element.bounds.width + ctxt.intraNeumeSpacing;
	
	          // round the staffPosition to the nearest line
	          if (staffPosition > 0) staffPosition = staffPosition - (staffPosition - 1) % 2;else staffPosition = staffPosition - (staffPosition + 1) % 2;
	
	          // if we have a ledger line close by, then average out the distance between the two
	          var minLedgerSeperation = ctxt.staffInterval * 5;
	
	          if (_this2.ledgerLines.length > 0 && _this2.ledgerLines[_this2.ledgerLines.length - 1].x2 + minLedgerSeperation >= x1) {
	
	            // average out the distance
	            var half = (x1 - _this2.ledgerLines[_this2.ledgerLines.length - 1].x2) / 2;
	            _this2.ledgerLines[_this2.ledgerLines.length - 1].x2 += half;
	            x1 -= half;
	          }
	
	          // never let a ledger line extend past the staff width
	          if (x2 > _this2.staffRight) x2 = _this2.staffRight;
	
	          // finally, add the ledger line
	          _this2.ledgerLines.push({
	            x1: x1,
	            x2: x2,
	            staffPosition: staffPosition
	          });
	        }
	      };
	
	      var epismata = []; // keep track of epismata in case we can connect some
	      var startBrace = null,
	          startBraceNotationIndex = 0;
	      var minY = Number.MAX_VALUE,
	          maxY = Number.MIN_VALUE; // for braces
	
	      // make a final pass over all of the notes to add any necessary
	      // ledger lines and to smooth out epismata
	      for (var i = this.notationsStartIndex; i < lastIndex; i++) {
	
	        minY = Math.min(minY, notations[i].bounds.y);
	        maxY = Math.max(maxY, notations[i].bounds.bottom());
	
	        if (notations[i].constructor === _ExsurgeChant.Custos) {
	          processElementForLedgerLine(notations[i]);
	          continue;
	        }
	
	        // if it's not a neume then just skip here
	        if (!notations[i].isNeume) continue;
	
	        var neume = notations[i];
	
	        for (var j = 0; j < neume.notes.length; j++) {
	          var k,
	              note = neume.notes[j];
	
	          processElementForLedgerLine(note, neume.bounds.x, neume.bounds.y);
	
	          // blend epismata as we're able
	          for (k = 0; k < note.epismata.length; k++) {
	
	            var episema = note.epismata[k];
	
	            var spaceBetweenEpismata = 0;
	
	            // calculate the distance between the last epismata and this one...
	            // lots of code for a simple: currEpismata.left - prevEpismata.right
	            if (epismata.length > 0) spaceBetweenEpismata = neume.bounds.x + episema.bounds.x - (epismata[epismata.length - 1].note.neume.bounds.x + epismata[epismata.length - 1].bounds.right());
	
	            // we try to blend the episema if we're able.
	            if (epismata.length === 0 || epismata[epismata.length - 1].positionHint !== episema.positionHint || epismata[epismata.length - 1].terminating === true || epismata[epismata.length - 1].alignment === _ExsurgeChant2.HorizontalEpisemaAlignment.Left || episema.alignment === _ExsurgeChant2.HorizontalEpisemaAlignment.Right || spaceBetweenEpismata > ctxt.intraNeumeSpacing * 2) {
	
	              // start a new set of epismata to potentially blend
	              epismata = [];
	              epismata.push(episema);
	            } else {
	              // blend all previous with this one
	              var newY;
	
	              if (episema.positionHint === _ExsurgeChant2.MarkingPositionHint.Below) newY = Math.max(episema.bounds.y, epismata[epismata.length - 1].bounds.y);else newY = Math.min(episema.bounds.y, epismata[epismata.length - 1].bounds.y);
	
	              if (episema.bounds.y !== newY) episema.bounds.y = newY;else {
	                for (var l = 0; l < epismata.length; l++) {
	                  epismata[l].bounds.y = newY;
	                }
	              }
	
	              // extend the last episema to meet the new one
	              var newWidth = neume.bounds.x + episema.bounds.x - (epismata[epismata.length - 1].note.neume.bounds.x + epismata[epismata.length - 1].bounds.x);
	              epismata[epismata.length - 1].bounds.width = newWidth;
	
	              epismata.push(episema);
	            }
	          }
	
	          if (note.braceEnd) {
	
	            // calculate the y value of the brace by iterating over all notations
	            // under/over the brace.
	            var y;
	            var dy = ctxt.intraNeumeSpacing / 2; // some safe space between brace and notes.
	            if (startBrace === null) {
	              // fixme: this brace must have started on the previous line...what to do here, draw half a brace?
	            } else {
	                if (startBrace.isAbove) {
	                  y = ctxt.calculateHeightFromStaffPosition(4);
	                  for (k = startBraceNotationIndex; k <= i; k++) {
	                    y = Math.min(y, notations[k].bounds.y - dy);
	                  }
	                } else {
	                  y = ctxt.calculateHeightFromStaffPosition(-4);
	                  for (k = startBraceNotationIndex; k <= i; k++) {
	                    y = Math.max(y, notations[k].bounds.y + dy);
	                  }
	                }
	
	                var addAcuteAccent = false;
	
	                if (startBrace.shape === _ExsurgeChant2.BraceShape.RoundBrace) {
	
	                  this.braces.push(new _Exsurge2.RoundBraceVisualizer(ctxt, startBrace.getAttachmentX(), note.braceEnd.getAttachmentX(), y, startBrace.isAbove));
	                } else {
	
	                  if (startBrace.shape === _ExsurgeChant2.BraceShape.AccentedCurlyBrace) addAcuteAccent = true;
	
	                  this.braces.push(new _Exsurge2.CurlyBraceVisualizer(ctxt, startBrace.getAttachmentX(), note.braceEnd.getAttachmentX(), y, startBrace.isAbove, addAcuteAccent));
	                }
	              }
	          }
	
	          if (note.braceStart) {
	            startBrace = note.braceStart;
	            startBraceNotationIndex = i;
	          }
	
	          // update the active brace y position if there is one
	          if (startBrace !== null) {
	            if (startBrace.isAbove) startBrace.bounds.y = Math.min(startBrace.bounds.y, note.bounds.y);else startBrace.bounds.y = Math.max(startBrace.bounds.y, note.bounds.bottom());
	          }
	        }
	      }
	
	      // if we still have an active brace, that means it spands two chant lines!
	      if (startBrace !== null) {
	        startBrace = startBrace;
	      }
	
	      // don't forget to also include the final custos, which may need a ledger line too
	      if (this.custos) processElementForLedgerLine(this.custos);
	    }
	
	    // this is where the real core of positioning neumes takes place
	    // returns true if positioning was able to fit the neume before rightNotationBoundary.
	    // returns false if cannot fit before given right margin.
	    // fixme: if this returns false, shouldn't we set the connectors on prev to be activated?!
	
	  }, {
	    key: 'positionNotationElement',
	    value: function positionNotationElement(ctxt, prevWithLyrics, prev, curr, rightNotationBoundary) {
	
	      var i;
	
	      // To begin we just place the current notation right after the previous,
	      // irrespective of lyrics.
	      curr.bounds.x = prev.bounds.right() + prev.trailingSpace;
	
	      // if the previous notation has no lyrics, then we simply make sure the
	      // current notation with lyrics is in the bounds of the line
	      if (prevWithLyrics === null) {
	
	        var maxRight = curr.bounds.right() + curr.trailingSpace;
	
	        // if the lyric left is negative, then offset the neume appropriately
	        for (i = 0; i < curr.lyrics.length; i++) {
	
	          curr.lyrics[i].setNeedsConnector(false); // we hope for the best!
	
	          if (curr.getLyricLeft(i) < 0) curr.bounds.x += -curr.getLyricLeft(i);
	
	          maxRight = Math.max(maxRight, curr.getLyricRight(i));
	        }
	
	        if (maxRight > rightNotationBoundary) return false;else return true;
	      }
	
	      // if the curr notation has no lyrics, then we force the prev notation
	      // with lyrics to have syllable connectors.
	      if (curr.hasLyrics() === false) {
	
	        for (i = 0; i < prevWithLyrics.lyrics.length; i++) {
	
	          if (prevWithLyrics.lyrics[i] !== null && prevWithLyrics.lyrics[i].allowsConnector()) prevWithLyrics.lyrics[i].setNeedsConnector(true);
	        }
	
	        if (curr.bounds.right() + curr.trailingSpace < rightNotationBoundary) return true;else return false;
	      }
	
	      // if we have multiple lyrics on the current or the previous notation,
	      // then we simplify the process. We don't try to eliminate syllable
	      // connectors but we require them on every syllable in the previous
	      // notation that permits a connector.
	      //
	      // A nice (but probably tricky) enhancement would be to combine lyrics
	      // when possible, taking into consideration hyphenation of each syllable!
	      var lyricCount = Math.max(prevWithLyrics.lyrics.length, curr.lyrics.length);
	
	      if (lyricCount > 1) {
	
	        var prevLyricRightMax = Number.MIN_VALUE;
	        var currLyricLeftMin = Number.MAX_VALUE;
	        var currLyricRightMax = Number.MIN_VALUE;
	
	        for (i = 0; i < lyricCount; i++) {
	
	          if (i < prevWithLyrics.lyrics.length && prevWithLyrics.lyrics[i] !== null) {
	
	            var right = prevWithLyrics.getLyricRight(i);
	
	            if (prevWithLyrics.lyrics[i].allowsConnector()) {
	              prevWithLyrics.lyrics[i].setNeedsConnector(true);
	              right += prevWithLyrics.lyrics[i].widthWithConnector - prevWithLyrics.lyrics[i].widthWithoutConnector;
	            } else right += ctxt.minLyricWordSpacing;
	
	            prevLyricRightMax = Math.max(prevLyricRightMax, right);
	          }
	
	          if (i < curr.lyrics.length && curr.lyrics[i] !== null) {
	            currLyricLeftMin = Math.min(currLyricLeftMin, curr.getLyricLeft(i));
	            currLyricRightMax = Math.max(currLyricRightMax, curr.getLyricRight(i));
	          }
	        }
	
	        // if the lyrics overlap, then we need to shift over the current element a bit
	        if (prevLyricRightMax > currLyricLeftMin) {
	          curr.bounds.x += prevLyricRightMax - currLyricLeftMin;
	          currLyricRightMax += prevLyricRightMax - currLyricLeftMin;
	        }
	
	        if (curr.bounds.right() < rightNotationBoundary && currLyricRightMax <= this.staffRight) return true;else {
	          curr.bounds.x = 0;
	          return false;
	        }
	      }
	
	      // handling single lyric lines is a little more nuanced, since we carefully
	      // eliminate syllable connectors when we're able...
	      curr.lyrics[0].setNeedsConnector(false); // we hope for the best!
	
	      var currLyricLeft = curr.getLyricLeft(0);
	      var prevLyricRight = prevWithLyrics.getLyricRight(0);
	
	      if (prevWithLyrics.lyrics[0].allowsConnector() === false) {
	
	        // No connector needed, but include space between words if necessary!
	        if (prevLyricRight + ctxt.minLyricWordSpacing > currLyricLeft) {
	          // push the current element over a bit.
	          curr.bounds.x += prevLyricRight + ctxt.minLyricWordSpacing - currLyricLeft;
	        }
	      } else {
	
	        // we may need a connector yet...
	
	        if (prevLyricRight > currLyricLeft) {
	          // in this case, the lyric elements actually overlap.
	          // so nope, no connector needed. instead, we just place the lyrics together
	          // fixme: for better text layout, we could actually use the kerning values
	          // between the prev and curr lyric elements!
	          curr.bounds.x += prevLyricRight - currLyricLeft;
	        } else {
	
	          // bummer, looks like we couldn't merge the syllables together. Better add a connector...
	          prevWithLyrics.lyrics[0].setNeedsConnector(true);
	          prevLyricRight = prevWithLyrics.getLyricRight(0);
	
	          if (prevLyricRight > currLyricLeft) curr.bounds.x += prevLyricRight - currLyricLeft;
	        }
	      }
	
	      if (curr.bounds.right() + curr.trailingSpace < rightNotationBoundary && curr.getLyricRight(0) <= this.staffRight) return true;
	
	      // if we made it this far, then the element won't fit on this line.
	      // set the position of the current element to the beginning of a chant line,
	      // and mark the previous lyric as connecting if needed.
	      // curr.bounds.x = this.startingClef.bounds.right();
	
	      if (prevWithLyrics.hasLyrics() && prevWithLyrics.lyrics[0].allowsConnector()) prevWithLyrics.lyrics[0].setNeedsConnector(true);
	
	      return false;
	    }
	  }]);
	
	  return ChantLine;
	}(_Exsurge2.ChantLayoutElement);

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.Virgula = exports.Accidental = exports.AccidentalType = exports.DoubleBar = exports.FullBar = exports.HalfBar = exports.QuarterBar = exports.Divider = exports.Custos = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	var _Exsurge2 = __webpack_require__(4);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	/*
	 *
	 */
	
	var Custos = exports.Custos = function (_ChantNotationElement) {
	  _inherits(Custos, _ChantNotationElement);
	
	  // if auto is true, then the custos will automatically try to determine it's height based on
	  // subsequent notations
	
	  function Custos() {
	    var auto = arguments.length <= 0 || arguments[0] === undefined ? false : arguments[0];
	
	    _classCallCheck(this, Custos);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(Custos).call(this));
	
	    _this.auto = auto;
	    _this.staffPosition = 0; // default sane value
	    return _this;
	  }
	
	  _createClass(Custos, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Custos.prototype), 'performLayout', this).call(this, ctxt);
	
	      var glyphCode;
	
	      if (this.auto) {
	
	        var neume = ctxt.findNextNeume();
	
	        if (neume) this.staffPosition = ctxt.activeClef.pitchToStaffPosition(neume.notes[0].pitch);
	      }
	
	      var glyph = new _Exsurge2.GlyphVisualizer(ctxt, Custos.getGlyphCode(this.staffPosition));
	      glyph.setStaffPosition(ctxt, this.staffPosition);
	      this.addVisualizer(glyph);
	
	      this.finishLayout(ctxt);
	    }
	
	    // called when layout has changed and our dependencies are no longer good
	
	  }, {
	    key: 'resetDependencies',
	    value: function resetDependencies() {
	
	      // we only need to resolve new dependencies if we're an automatic custos
	      if (this.auto) this.needsLayout = true;
	    }
	  }], [{
	    key: 'getGlyphCode',
	    value: function getGlyphCode(staffPosition) {
	
	      if (staffPosition <= 2) {
	
	        // ascending custodes
	        if (Math.abs(staffPosition) % 2 === 1) return _Exsurge2.GlyphCode.CustosLong;else return _Exsurge2.GlyphCode.CustosShort;
	      } else {
	
	        // descending custodes
	        if (Math.abs(staffPosition) % 2 === 1) return _Exsurge2.GlyphCode.CustosDescLong;else return _Exsurge2.GlyphCode.CustosDescShort;
	      }
	    }
	  }]);
	
	  return Custos;
	}(_Exsurge2.ChantNotationElement);
	
	/*
	 * Divider
	 */
	
	
	var Divider = exports.Divider = function (_ChantNotationElement2) {
	  _inherits(Divider, _ChantNotationElement2);
	
	  function Divider() {
	    _classCallCheck(this, Divider);
	
	    var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(Divider).call(this));
	
	    _this2.isDivider = true;
	    _this2.resetsAccidentals = true;
	    return _this2;
	  }
	
	  return Divider;
	}(_Exsurge2.ChantNotationElement);
	
	/*
	 * QuarterBar
	 */
	
	
	var QuarterBar = exports.QuarterBar = function (_Divider) {
	  _inherits(QuarterBar, _Divider);
	
	  function QuarterBar() {
	    _classCallCheck(this, QuarterBar);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(QuarterBar).apply(this, arguments));
	  }
	
	  _createClass(QuarterBar, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(QuarterBar.prototype), 'performLayout', this).call(this, ctxt);
	      this.addVisualizer(new _Exsurge2.DividerLineVisualizer(ctxt, 2, 4));
	
	      this.origin.x = this.bounds.width / 2;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return QuarterBar;
	}(Divider);
	
	/*
	 * HalfBar
	 */
	
	
	var HalfBar = exports.HalfBar = function (_Divider2) {
	  _inherits(HalfBar, _Divider2);
	
	  function HalfBar() {
	    _classCallCheck(this, HalfBar);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(HalfBar).apply(this, arguments));
	  }
	
	  _createClass(HalfBar, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(HalfBar.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.addVisualizer(new _Exsurge2.DividerLineVisualizer(ctxt, -2, 2));
	
	      this.origin.x = this.bounds.width / 2;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return HalfBar;
	}(Divider);
	
	/*
	 * FullBar
	 */
	
	
	var FullBar = exports.FullBar = function (_Divider3) {
	  _inherits(FullBar, _Divider3);
	
	  function FullBar() {
	    _classCallCheck(this, FullBar);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(FullBar).apply(this, arguments));
	  }
	
	  _createClass(FullBar, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(FullBar.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.addVisualizer(new _Exsurge2.DividerLineVisualizer(ctxt, -3, 3));
	
	      this.origin.x = this.bounds.width / 2;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return FullBar;
	}(Divider);
	
	/*
	 * DoubleBar
	 */
	
	
	var DoubleBar = exports.DoubleBar = function (_Divider4) {
	  _inherits(DoubleBar, _Divider4);
	
	  function DoubleBar() {
	    _classCallCheck(this, DoubleBar);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(DoubleBar).apply(this, arguments));
	  }
	
	  _createClass(DoubleBar, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(DoubleBar.prototype), 'performLayout', this).call(this, ctxt);
	
	      var line0 = new _Exsurge2.DividerLineVisualizer(ctxt, -3, 3);
	      line0.bounds.x = 0;
	      this.addVisualizer(line0);
	
	      var line1 = new _Exsurge2.DividerLineVisualizer(ctxt, -3, 3);
	      line1.bounds.x = ctxt.intraNeumeSpacing * 2;
	      this.addVisualizer(line1);
	
	      this.origin.x = this.bounds.width / 2;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return DoubleBar;
	}(Divider);
	
	var AccidentalType = exports.AccidentalType = {
	  Flat: -1,
	  Natural: 0,
	  Sharp: 1
	};
	
	/*
	 * Accidental
	 */
	
	var Accidental = exports.Accidental = function (_ChantNotationElement3) {
	  _inherits(Accidental, _ChantNotationElement3);
	
	  function Accidental(staffPosition, accidentalType) {
	    _classCallCheck(this, Accidental);
	
	    var _this7 = _possibleConstructorReturn(this, Object.getPrototypeOf(Accidental).call(this));
	
	    _this7.isAccidental = true;
	    _this7.keepWithNext = true; // accidentals should always stay connected...
	
	    _this7.staffPosition = staffPosition;
	    _this7.accidentalType = accidentalType;
	    return _this7;
	  }
	
	  _createClass(Accidental, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Accidental.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.addVisualizer(this.createGlyphVisualizer(ctxt));
	
	      this.finishLayout(ctxt);
	    }
	
	    // creation of the glyph visualizer is refactored out or performLayout
	    // so that clefs can use the same logic for their accidental glyph
	
	  }, {
	    key: 'createGlyphVisualizer',
	    value: function createGlyphVisualizer(ctxt) {
	
	      var glyphCode = _Exsurge2.GlyphCode.Flat;
	
	      switch (this.accidentalType) {
	        case AccidentalType.Natural:
	          glyphCode = _Exsurge2.GlyphCode.Natural;
	          break;
	        case AccidentalType.Sharp:
	          glyphCode = _Exsurge2.GlyphCode.Sharp;
	          break;
	        default:
	          glyphCode = _Exsurge2.GlyphCode.Flat;
	          break;
	      }
	
	      var glyph = new _Exsurge2.GlyphVisualizer(ctxt, glyphCode);
	      glyph.setStaffPosition(ctxt, this.staffPosition);
	
	      return glyph;
	    }
	  }, {
	    key: 'adjustStep',
	    value: function adjustStep(step) {
	      switch (this.accidentalType) {
	        case AccidentalType.Flat:
	          if (step === Step.Ti) return Step.Te;
	          if (step === Step.Mi) return Step.Me;
	          break;
	        case AccidentalType.Sharp:
	          if (step === Step.Do) return Step.Du;
	          if (step === Step.Fa) return Step.Fu;
	          break;
	        case AccidentalType.Natural:
	          if (step === Step.Te) return Step.Ti;
	          if (step === Step.Me) return Step.Mi;
	          if (step === Step.Du) return Step.Do;
	          if (step === Step.Fu) return Step.Fa;
	          break;
	      }
	
	      // no adjustment needed
	      return step;
	    }
	  }, {
	    key: 'applyToPitch',
	    value: function applyToPitch(pitch) {
	
	      // fixme: this is broken since we changed to staff positions
	
	      // no adjusment needed
	      if (this.octave !== pitch.octave) return;
	
	      pitch.step = this.adjustStep(pitch.step);
	    }
	  }]);
	
	  return Accidental;
	}(_Exsurge2.ChantNotationElement);
	
	/*
	 * Virgula
	 */
	
	
	var Virgula = exports.Virgula = function (_Divider5) {
	  _inherits(Virgula, _Divider5);
	
	  function Virgula() {
	    _classCallCheck(this, Virgula);
	
	    // unlike other dividers a virgula does not reset accidentals
	
	    var _this8 = _possibleConstructorReturn(this, Object.getPrototypeOf(Virgula).call(this));
	
	    _this8.resetsAccidentals = false;
	
	    // the staff position of the virgula is customizable, so that it
	    // can be placed on different lines (top or bottom) depending on the
	    // notation tradition of what is being notated (e.g., Benedictine has it
	    //  on top line, Norbertine at the bottom)
	    _this8.staffPosition = 3;
	    return _this8;
	  }
	
	  _createClass(Virgula, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Virgula.prototype), 'performLayout', this).call(this, ctxt);
	
	      var glyph = new _Exsurge2.GlyphVisualizer(ctxt, _Exsurge2.GlyphCode.Virgula);
	      glyph.setStaffPosition(ctxt, this.staffPosition);
	
	      this.addVisualizer(glyph);
	
	      this.origin.x = this.bounds.width / 2;
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Virgula;
	}(Divider);

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.BracePoint = exports.BraceAttachment = exports.BraceShape = exports.Mora = exports.Ictus = exports.HorizontalEpisema = exports.HorizontalEpisemaAlignment = exports.AcuteAccent = exports.MarkingPositionHint = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	var _Exsurge2 = __webpack_require__(4);
	
	var _Exsurge3 = __webpack_require__(6);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; } //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	// for positioning markings on notes
	var MarkingPositionHint = exports.MarkingPositionHint = {
	  Default: 0,
	  Above: 1,
	  Below: 2
	};
	
	var AcuteAccent = exports.AcuteAccent = function (_GlyphVisualizer) {
	  _inherits(AcuteAccent, _GlyphVisualizer);
	
	  function AcuteAccent(ctxt, note) {
	    _classCallCheck(this, AcuteAccent);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(AcuteAccent).call(this, ctxt, _Exsurge2.GlyphCode.AcuteAccent));
	
	    _this.note = note;
	    _this.positionHint = MarkingPositionHint.Above;
	    return _this;
	  }
	
	  _createClass(AcuteAccent, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      this.bounds.x += this.bounds.width / 2; // center on the note itself
	
	      // this puts the acute accent either over the staff lines, or over the note if the
	      // note is above the staff lines
	      this.setStaffPosition(ctxt, Math.max(this.note.staffPosition + 1, 4));
	    }
	  }]);
	
	  return AcuteAccent;
	}(_Exsurge2.GlyphVisualizer);
	
	// for positioning markings on notes
	
	
	var HorizontalEpisemaAlignment = exports.HorizontalEpisemaAlignment = {
	  Default: 0,
	  Left: 1,
	  Center: 2,
	  Right: 3
	};
	
	/*
	 * HorizontalEpisema
	 *
	 * A horizontal episema marking is it's own visualizer (that is, it implements createSvgFragment)
	 */
	
	var HorizontalEpisema = exports.HorizontalEpisema = function (_ChantLayoutElement) {
	  _inherits(HorizontalEpisema, _ChantLayoutElement);
	
	  function HorizontalEpisema(note) {
	    _classCallCheck(this, HorizontalEpisema);
	
	    var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(HorizontalEpisema).call(this));
	
	    _this2.note = note;
	
	    _this2.positionHint = MarkingPositionHint.Default;
	    _this2.terminating = false; // indicates if this episema should terminate itself or not
	    _this2.alignment = HorizontalEpisemaAlignment.Default;
	    return _this2;
	  }
	
	  _createClass(HorizontalEpisema, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      // following logic helps to keep the episemae away from staff lines if they get too close
	      // the placement is based on a review of the Vatican and solesmes editions, which
	      // seem to always place the epismata centered between staff lines. Probably helps
	      // for visual layout, rather than letting epismata be at various heights.
	
	      var y = 0,
	          step;
	      var minDistanceAway = ctxt.staffInterval * 0.4; // min distance from neume
	
	      if (this.positionHint === MarkingPositionHint.Below) {
	        y = this.note.bounds.bottom() + minDistanceAway; // the highest the line could be at
	        step = Math.floor(y / ctxt.staffInterval);
	
	        // if it's an odd step, that means we're on a staff line,
	        // so we shift to between the staff line
	        if (Math.abs(step % 2) === 1) step = step + 1;
	      } else {
	        y = this.note.bounds.y - minDistanceAway; // the lowest the line could be at
	        step = Math.ceil(y / ctxt.staffInterval);
	
	        // if it's an odd step, that means we're on a staff line,
	        // so we shift to between the staff line
	        if (Math.abs(step % 2) === 1) step = step - 1;
	      }
	
	      y = step * ctxt.staffInterval;
	
	      var glyphCode = this.note.glyphVisualizer.glyphCode;
	      var width;
	
	      // The porrectus requires special handling of the note width,
	      // otherwise the width is just that of the note itself
	      if (glyphCode === _Exsurge2.GlyphCode.Porrectus1 || glyphCode === _Exsurge2.GlyphCode.Porrectus2 || glyphCode === _Exsurge2.GlyphCode.Porrectus3 || glyphCode === _Exsurge2.GlyphCode.Porrectus4) width = ctxt.staffInterval;else width = this.note.bounds.width;
	
	      var x = this.note.bounds.x;
	
	      // also, the position hint can affect the x/width of the episema
	      if (this.alignment === HorizontalEpisemaAlignment.Left) {
	        width *= .80;
	      } else if (this.alignment === HorizontalEpisemaAlignment.Center) {
	        x += width * .20;
	        width *= .60;
	      } else if (this.alignment === HorizontalEpisemaAlignment.Right) {
	        x += width * .20;
	        width *= .80;
	      }
	
	      this.bounds.x = x;
	      this.bounds.y = y;
	      this.bounds.width = width;
	      this.bounds.height = ctxt.episemaLineWeight;
	
	      this.origin.x = 0;
	      this.origin.y = 0;
	    }
	  }, {
	    key: 'createSvgFragment',
	    value: function createSvgFragment(ctxt) {
	
	      return _Exsurge2.QuickSvg.createFragment('rect', {
	        'x': this.bounds.x,
	        'y': this.bounds.y,
	        'width': this.bounds.width,
	        'height': this.bounds.height,
	        'fill': ctxt.neumeLineColor,
	        'class': 'horizontalEpisema'
	      });
	    }
	  }]);
	
	  return HorizontalEpisema;
	}(_Exsurge2.ChantLayoutElement);
	
	/*
	 * Ictus
	 */
	
	
	var Ictus = exports.Ictus = function (_GlyphVisualizer2) {
	  _inherits(Ictus, _GlyphVisualizer2);
	
	  function Ictus(ctxt, note) {
	    _classCallCheck(this, Ictus);
	
	    var _this3 = _possibleConstructorReturn(this, Object.getPrototypeOf(Ictus).call(this, ctxt, _Exsurge2.GlyphCode.VerticalEpisemaAbove));
	
	    _this3.note = note;
	    _this3.positionHint = MarkingPositionHint.Default;
	    return _this3;
	  }
	
	  _createClass(Ictus, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      var glyphCode;
	
	      // fixme: this positioning logic doesn't work for the ictus on a virga apparently...?
	
	      if (this.positionHint === MarkingPositionHint.Above) {
	        glyphCode = _Exsurge2.GlyphCode.VerticalEpisemaAbove;
	      } else {
	        glyphCode = _Exsurge2.GlyphCode.VerticalEpisemaBelow;
	      }
	
	      var staffPosition = this.note.staffPosition;
	
	      var horizontalOffset = this.note.bounds.width / 2;
	      var verticalOffset = 0;
	
	      switch (glyphCode) {
	        case _Exsurge2.GlyphCode.VerticalEpisemaAbove:
	          if (staffPosition % 2 === 0) verticalOffset -= ctxt.staffInterval * 1.5;else verticalOffset -= ctxt.staffInterval * .9;
	          break;
	
	        case _Exsurge2.GlyphCode.VerticalEpisemaBelow:
	        default:
	          if (staffPosition % 2 === 0) verticalOffset += ctxt.staffInterval * 1.5;else verticalOffset += ctxt.staffInterval * .8;
	          break;
	      }
	
	      this.setGlyph(ctxt, glyphCode);
	      this.setStaffPosition(ctxt, staffPosition);
	
	      this.bounds.x = this.note.bounds.x + horizontalOffset - this.origin.x;
	      this.bounds.y += verticalOffset;
	    }
	  }]);
	
	  return Ictus;
	}(_Exsurge2.GlyphVisualizer);
	
	/*
	 * Mora
	 */
	
	
	var Mora = exports.Mora = function (_GlyphVisualizer3) {
	  _inherits(Mora, _GlyphVisualizer3);
	
	  function Mora(ctxt, note) {
	    _classCallCheck(this, Mora);
	
	    var _this4 = _possibleConstructorReturn(this, Object.getPrototypeOf(Mora).call(this, ctxt, _Exsurge2.GlyphCode.Mora));
	
	    _this4.note = note;
	    _this4.positionHint = MarkingPositionHint.Default;
	    return _this4;
	  }
	
	  _createClass(Mora, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	
	      var staffPosition = this.note.staffPosition;
	
	      this.setStaffPosition(ctxt, staffPosition);
	
	      var verticalOffset = 0;
	      if (this.positionHint === MarkingPositionHint.Above) {
	        if (staffPosition % 2 === 0) verticalOffset -= ctxt.staffInterval + ctxt.staffInterval * .75;else verticalOffset -= ctxt.staffInterval * .75;
	      } else if (this.positionHint === MarkingPositionHint.Below) {
	        if (staffPosition % 2 === 0) verticalOffset += ctxt.staffInterval + ctxt.staffInterval * .75;else verticalOffset += ctxt.staffInterval * .75;
	      } else {
	        if (Math.abs(staffPosition) % 2 === 1) verticalOffset -= ctxt.staffInterval * .75;
	      }
	
	      this.bounds.x += this.note.bounds.right() + ctxt.staffInterval / 4.0;
	      this.bounds.y += verticalOffset;
	    }
	  }]);
	
	  return Mora;
	}(_Exsurge2.GlyphVisualizer);
	
	// indicates the shape of the brace
	
	
	var BraceShape = exports.BraceShape = {
	  RoundBrace: 0,
	  CurlyBrace: 1,
	  AccentedCurlyBrace: 2
	};
	
	// indicates how the brace is alignerd to the note to which it's connected
	var BraceAttachment = exports.BraceAttachment = {
	  Left: 0,
	  Right: 1
	};
	
	var BracePoint = exports.BracePoint = function (_ChantLayoutElement2) {
	  _inherits(BracePoint, _ChantLayoutElement2);
	
	  function BracePoint(note, isAbove, shape, attachment) {
	    _classCallCheck(this, BracePoint);
	
	    var _this5 = _possibleConstructorReturn(this, Object.getPrototypeOf(BracePoint).call(this));
	
	    _this5.note = note;
	    _this5.isAbove = isAbove;
	    _this5.shape = shape;
	    _this5.attachment = attachment;
	    return _this5;
	  }
	
	  _createClass(BracePoint, [{
	    key: 'getAttachmentX',
	    value: function getAttachmentX() {
	      if (this.attachment === BraceAttachment.Left) return this.note.neume.bounds.x + this.note.bounds.x;else return this.note.neume.bounds.x + this.note.bounds.right();
	    }
	  }]);
	
	  return BracePoint;
	}(_Exsurge2.ChantLayoutElement);

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.Gabc = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	//
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var _Exsurge = __webpack_require__(1);
	
	var _Exsurge2 = __webpack_require__(4);
	
	var _Exsurge3 = __webpack_require__(6);
	
	var _ExsurgeChant = __webpack_require__(9);
	
	var Markings = _interopRequireWildcard(_ExsurgeChant);
	
	var _ExsurgeChant2 = __webpack_require__(8);
	
	var Signs = _interopRequireWildcard(_ExsurgeChant2);
	
	var _ExsurgeChant3 = __webpack_require__(11);
	
	var Neumes = _interopRequireWildcard(_ExsurgeChant3);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// reusable reg exps
	var __altTranslationRegex = /<alt>(.*?)<\/alt>|\[(alt:)?(.*?)\]/g;
	var __notationsRegex_group_insideBraces = 1;
	var __bracketedCommandRegex = /^([a-z]+):(.*)/;
	
	// reusable reg exps
	var __syllablesRegex = /(?=\S)((?:<v>[\s\S]*<\/v>|[^(])*)(?:\(?([^)]*)\)?)?/g;
	var __notationsRegex = /z0|z|Z|::|:|[,;][1-6]?|`|[cf][1-4]|cb[1-4]|\/+| |\!|-?[a-mA-M][oOwWvVrRsxy#~\+><_\.'012345]*(?:\[[^\]]*\]?)*|\{([^}]+)\}?/g;  //`
	
	// for the brace string inside of [ and ] in notation data
	// the capturing groups are:
	//  1. o or u, to indicate over or under
	//  2. b, cb, or cba, to indicate the brace type
	//  3. 0 or 1 to indicate the attachment point
	//  4. {}( or ) to indicate opening/closing (this group will be null if the metric version is used)
	//  5. a float indicating the millimeter length of the brace (not supported yet)
	var __braceSpecRegex = /([ou])(b|cb|cba):([01])(?:([{}])|;(\d*(?:\.\d+)?)mm)/;
	
	var Gabc = exports.Gabc = function () {
	  function Gabc() {
	    _classCallCheck(this, Gabc);
	  }
	
	  _createClass(Gabc, null, [{
	    key: 'createMappingsFromSource',
	
	
	    // takes gabc source code (without the header info) and returns an array
	    // of ChantMappings describing the chant. A chant score can then be created
	    // fron the chant mappings and later updated via updateMappings() if need
	    // be...
	    value: function createMappingsFromSource(ctxt, gabcSource) {
	
	      var words = this.splitWords(gabcSource);
	
	      // set the default clef
	      ctxt.activeClef = _Exsurge3.Clef.default();
	
	      var mappings = this.createMappingsFromWords(ctxt, words, function (clef) {
	        return ctxt.activeClef = clef;
	      });
	
	      // always set the last notation to have a trailingSpace of 0. This makes layout for the last chant line simpler
	      if (mappings.length > 0 && mappings[mappings.length - 1].notations.length > 0) mappings[mappings.length - 1].notations[mappings[mappings.length - 1].notations.length - 1].trailingSpace = 0;
	
	      return mappings;
	    }
	
	    // A simple general purpose diff algorithm adapted here for comparing
	    // an array of existing mappings with an updated list of gabc words.
	    // note before is an array of mappings, and after is an array of strings
	    // (gabc words).
	    //
	    // This is definitely not the most effecient diff algorithm, but for our
	    // limited needs and source size it seems to work just fine...
	    //
	    // code is adapted from: https://github.com/paulgb/simplediff
	    //
	    // Returns:
	    //   A list of pairs, with the first part of the pair being one of three
	    //   strings ('-', '+', '=') and the second part being a list of values from
	    //   the original before and/or after lists. The first part of the pair
	    //   corresponds to whether the list of values is a deletion, insertion, or
	    //   unchanged, respectively.
	
	  }, {
	    key: 'diffDescriptorsAndNewWords',
	    value: function diffDescriptorsAndNewWords(before, after) {
	
	      // Create a map from before values to their indices
	      var oldIndexMap = {},
	          i;
	      for (i = 0; i < before.length; i++) {
	        oldIndexMap[before[i].source] = oldIndexMap[before[i].source] || [];
	        oldIndexMap[before[i].source].push(i);
	      }
	
	      var overlap = [],
	          startOld,
	          startNew,
	          subLength,
	          inew;
	
	      startOld = startNew = subLength = 0;
	
	      for (inew = 0; inew < after.length; inew++) {
	        var _overlap = [];
	        oldIndexMap[after[inew]] = oldIndexMap[after[inew]] || [];
	        for (i = 0; i < oldIndexMap[after[inew]].length; i++) {
	          var iold = oldIndexMap[after[inew]][i];
	          // now we are considering all values of val such that
	          // `before[iold] == after[inew]`
	          _overlap[iold] = (iold && overlap[iold - 1] || 0) + 1;
	          if (_overlap[iold] > subLength) {
	            // this is the largest substring seen so far, so store its indices
	            subLength = _overlap[iold];
	            startOld = iold - subLength + 1;
	            startNew = inew - subLength + 1;
	          }
	        }
	        overlap = _overlap;
	      }
	
	      if (subLength === 0) {
	        // If no common substring is found, we return an insert and delete...
	        var result = [];
	
	        if (before.length) result.push(['-', before]);
	
	        if (after.length) result.push(['+', after]);
	
	        return result;
	      }
	
	      // ...otherwise, the common substring is unchanged and we recursively
	      // diff the text before and after that substring
	      return [].concat(this.diffDescriptorsAndNewWords(before.slice(0, startOld), after.slice(0, startNew)), [['=', after.slice(startNew, startNew + subLength)]], this.diffDescriptorsAndNewWords(before.slice(startOld + subLength), after.slice(startNew + subLength)));
	    }
	
	    // this function essentially performs and applies a rudimentary diff between a
	    // previously parsed set of mappings and between a new gabc source text.
	    // the mappings array passed in is changed in place to be updated from the
	    // new source
	
	  }, {
	    key: 'updateMappingsFromSource',
	    value: function updateMappingsFromSource(ctxt, mappings, newGabcSource) {
	
	      // always remove the last old mapping since it's spacing/trailingSpace is handled specially
	      mappings.pop();
	
	      var newWords = this.splitWords(newGabcSource);
	
	      var results = this.diffDescriptorsAndNewWords(mappings, newWords);
	
	      var index = 0,
	          j,
	          k;
	
	      ctxt.activeClef = _Exsurge3.Clef.default();
	
	      // apply the results to the mappings, marking notations that need to be processed
	      for (var i = 0; i < results.length; i++) {
	
	        var resultCode = results[i][0];
	        var resultValues = results[i][1];
	
	        if (resultCode === '=') {
	          // skip over ones that haven't changed, but updating the clef as we go
	          for (j = 0; j < resultValues.length; j++, index++) {
	            for (k = 0; k < mappings[index].notations.length; k++) {
	              // notify the notation that its dependencies are no longer valid
	              mappings[index].notations[k].resetDependencies();
	
	              if (mappings[index].notations[k].isClef) ctxt.activeClef = mappings[index].notations[k];
	            }
	          }
	        } else if (resultCode === '-') {
	          // delete elements that no longer exist, but first notify all
	          // elements of the change
	          mappings.splice(index, resultValues.length);
	        } else if (resultCode === '+') {
	          // insert new ones
	          for (j = 0; j < resultValues.length; j++) {
	            var mapping = this.createMappingFromWord(ctxt, resultValues[j]);
	
	            for (k = 0; k < mapping.notations.length; k++) {
	              if (mapping.notations[k].isClef) ctxt.activeClef = mapping.notations[k];
	            }mappings.splice(index++, 0, mapping);
	          }
	        }
	      }
	
	      // always set the last notation to have a trailingSpace of 0. This makes layout for the last chant line simpler
	      if (mappings.length > 0 && mappings[mappings.length - 1].notations.length > 0) mappings[mappings.length - 1].notations[mappings[mappings.length - 1].notations.length - 1].trailingSpace = 0;
	    }
	
	    // takes an array of gabc words (like that returned by splitWords below)
	    // and returns an array of ChantMapping objects, one for each word.
	
	  }, {
	    key: 'createMappingsFromWords',
	    value: function createMappingsFromWords(ctxt, words) {
	      var mappings = [];
	
	      for (var i = 0; i < words.length; i++) {
	        var word = words[i].trim();
	
	        if (word === '') continue;
	
	        var mapping = this.createMappingFromWord(ctxt, word);
	
	        if (mapping) mappings.push(mapping);
	      }
	
	      return mappings;
	    }
	
	    // takes a gabc word (like those returned by splitWords below) and returns
	    // a ChantMapping object that contains the gabc word source text as well
	    // as the generated notations.
	
	  }, {
	    key: 'createMappingFromWord',
	    value: function createMappingFromWord(ctxt, word) {
	
	      var matches = [];
	      var notations = [];
	      var currSyllable = 0;
	
	      while (match = __syllablesRegex.exec(word)) {
	        matches.push(match);
	      }for (var j = 0; j < matches.length; j++) {
	        var match = matches[j];
	
	        var lyricText = match[1].trim();
	        var notationData = match[2];
	
	        var items = this.parseNotations(ctxt, notationData);
	
	        if (items.length === 0) continue;
	
	        notations = notations.concat(items);
	
	        if (lyricText === '') continue;
	
	        // add the lyrics to the first notation that makes sense...
	        var notationWithLyrics = null;
	        for (var i = 0; i < items.length; i++) {
	          var cne = items[i];
	
	          if (cne.isAccidental || cne.constructor === Signs.Custos) continue;
	
	          notationWithLyrics = cne;
	          break;
	        }
	
	        if (notationWithLyrics === null) return notations;
	
	        var proposedLyricType;
	
	        // if it's not a neume or a TextOnly notation, then make the lyrics a directive
	        if (!cne.isNeume && cne.constructor !== _Exsurge3.TextOnly) proposedLyricType = _Exsurge2.LyricType.Directive;
	        // otherwise trye to guess the lyricType for the first lyric anyway
	        else if (currSyllable === 0 && j === matches.length - 1) proposedLyricType = _Exsurge2.LyricType.SingleSyllable;else if (currSyllable === 0 && j < matches.length - 1) proposedLyricType = _Exsurge2.LyricType.BeginningSyllable;else if (j === matches.length - 1) proposedLyricType = _Exsurge2.LyricType.EndingSyllable;else proposedLyricType = _Exsurge2.LyricType.MiddleSyllable;
	
	        currSyllable++;
	
	        // also, new words reset the accidentals, per the Solesmes style (see LU xviij)
	        if (proposedLyricType === _Exsurge2.LyricType.BeginningSyllable || proposedLyricType === _Exsurge2.LyricType.SingleSyllable) ctxt.activeClef.resetAccidentals();
	
	        var lyrics = this.createSyllableLyrics(ctxt, lyricText, proposedLyricType);
	
	        if (lyrics === null || lyrics.length === 0) continue;
	
	        notationWithLyrics.lyrics = lyrics;
	      }
	
	      return new _Exsurge3.ChantMapping(word, notations);
	    }
	
	    // returns an array of lyrics (an array because each syllable can have multiple lyrics)
	
	  }, {
	    key: 'createSyllableLyrics',
	    value: function createSyllableLyrics(ctxt, text, proposedLyricType) {
	
	      var lyrics = [];
	
	      // an extension to gabc: multiple lyrics per syllable can be separated by a |
	      var lyricTexts = text.split('|');
	
	      for (var i = 0; i < lyricTexts.length; i++) {
	
	        var lyricText = lyricTexts[i];
	
	        // gabc allows lyrics to indicate the centering part of the text by
	        // using braces to indicate how to center the lyric. So a lyric can
	        // look like "f{i}re" or "{fenced}" to center on the i or on the entire
	        // word, respectively. Here we determine if the lyric should be spaced
	        // manually with this method of using braces.
	        var centerStartIndex = lyricText.indexOf('{');
	        var centerLength = 0;
	
	        if (centerStartIndex >= 0) {
	          var indexClosingBracket = lyricText.indexOf('}');
	
	          if (indexClosingBracket >= 0 && indexClosingBracket > centerStartIndex) {
	            centerLength = indexClosingBracket - centerStartIndex - 1;
	
	            // strip out the brackets...is this better than string.replace?
	            lyricText = lyricText.substring(0, centerStartIndex) + lyricText.substring(centerStartIndex + 1, indexClosingBracket) + lyricText.substring(indexClosingBracket + 1, lyricText.length);
	          } else centerStartIndex = -1; // if there's no closing bracket, don't enable centering
	        }
	
	        var lyric = this.makeLyric(ctxt, lyricText, proposedLyricType);
	
	        // if we have manual lyric centering, then set it now
	        if (centerStartIndex >= 0) {
	          lyric.centerStartIndex = centerStartIndex;
	          lyric.centerLength = centerLength;
	        }
	
	        lyrics.push(lyric);
	      }
	
	      return lyrics;
	    }
	  }, {
	    key: 'makeLyric',
	    value: function makeLyric(ctxt, text, lyricType) {
	
	      if (text.length > 1 && text[text.length - 1] === '-') {
	        if (lyricType === _Exsurge2.LyricType.EndingSyllable) lyricType = _Exsurge2.LyricType.MiddleSyllable;else if (lyricType === _Exsurge2.LyricType.SingleSyllable) lyricType = _Exsurge2.LyricType.BeginningSyllable;
	
	        text = text.substring(0, text.length - 1);
	      }
	
	      var elides = false;
	      if (text.length > 1 && text[text.length - 1] === '_') {
	        // must be an elision
	        elides = true;
	        text = text.substring(0, text.length - 1);
	      }
	
	      if (text === "*" || text === "†") lyricType = _Exsurge2.LyricType.Directive;
	
	      var lyric = new _Exsurge2.Lyric(ctxt, text, lyricType);
	      lyric.elidesToNext = elides;
	
	      return lyric;
	    }
	
	    // takes a string of gabc notations and creates exsurge objects out of them.
	    // returns an array of notations.
	
	  }, {
	    key: 'parseNotations',
	    value: function parseNotations(ctxt, data) {
	      var _this = this;
	
	      // if there is no data, then this must be a text only object
	      if (!data) return [new _Exsurge3.TextOnly()];
	
	      var notations = [];
	      var notes = [];
	      var trailingSpace = -1;
	
	      var addNotation = function addNotation(notation) {
	
	        // first, if we have any notes left over, we create a neume out of them
	        if (notes.length > 0) {
	
	          // create neume(s)
	          var neumes = _this.createNeumesFromNotes(ctxt, notes, trailingSpace);
	          for (var i = 0; i < neumes.length; i++) {
	            notations.push(neumes[i]);
	          } // reset the trailing space
	          trailingSpace = -1;
	
	          notes = [];
	        }
	
	        // then, if we're passed a notation, let's add it
	        // also, perform chant logic here
	        if (notation !== null) {
	
	          if (notation.isClef) {
	            ctxt.activeClef = notation;
	          } else if (notation.isAccidental) ctxt.activeClef.activeAccidental = notation;else if (notation.resetsAccidentals) ctxt.activeClef.resetAccidentals();
	
	          notations.push(notation);
	        }
	      };
	
	      var atoms = data.match(__notationsRegex);
	
	      if (atoms === null) return notations;
	
	      for (var i = 0; i < atoms.length; i++) {
	
	        var atom = atoms[i];
	
	        // handle the clefs and dividers here
	        switch (atom) {
	          case ",":
	            addNotation(new Signs.QuarterBar());
	            break;
	          case "`":
	            addNotation(new Signs.Virgula());
	            break;
	          case ";":
	            addNotation(new Signs.HalfBar());
	            break;
	          case ":":
	            addNotation(new Signs.FullBar());
	            break;
	          case "::":
	            addNotation(new Signs.DoubleBar());
	            break;
	          // other gregorio dividers are not supported yet
	
	          case "c1":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(-3, 2));
	            break;
	
	          case "c2":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(-1, 2));
	            break;
	
	          case "c3":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(1, 2));
	            break;
	
	          case "c4":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(3, 2));
	            break;
	
	          case "f3":
	            addNotation(ctxt.activeClef = new _Exsurge3.FaClef(1, 2));
	            break;
	
	          case "f4":
	            addNotation(ctxt.activeClef = new _Exsurge3.FaClef(3, 2));
	            break;
	
	          case "cb1":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(-3, 2, new Signs.Accidental(-4, Signs.AccidentalType.Flat)));
	            break;
	
	          case "cb2":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(-1, 2, new Signs.Accidental(-2, Signs.AccidentalType.Flat)));
	            break;
	
	          case "cb3":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(1, 2, new Signs.Accidental(0, Signs.AccidentalType.Flat)));
	            break;
	
	          case "cb4":
	            addNotation(ctxt.activeClef = new _Exsurge3.DoClef(3, 2, new Signs.Accidental(2, Signs.AccidentalType.Flat)));
	            break;
	
	          case "z":
	            addNotation(new _Exsurge3.ChantLineBreak(true));
	            break;
	          case "Z":
	            addNotation(new _Exsurge3.ChantLineBreak(false));
	            break;
	          case "z0":
	            addNotation(new Signs.Custos(true));
	            break;
	
	          // spacing indicators
	          case "!":
	            trailingSpace = 0;
	            addNotation(null);
	            break;
	          case "/":
	            trailingSpace = ctxt.intraNeumeSpacing;
	            addNotation(null);
	            break;
	          case "//":
	            trailingSpace = ctxt.intraNeumeSpacing * 2;
	            addNotation(null);
	            break;
	          case ' ':
	            // fixme: is this correct? logically what is the difference in gabc
	            // between putting a space between notes vs putting '//' between notes?
	            trailingSpace = ctxt.intraNeumeSpacing * 2;
	            addNotation(null);
	            break;
	
	          default:
	            // might be a custos, might be an accidental, or might be a note
	            if (atom.length > 1 && atom[1] === '+') {
	              // custos
	              var custos = new Signs.Custos();
	
	              custos.staffPosition = this.gabcHeightToExsurgeHeight(data[0]);
	
	              addNotation(custos);
	            } else if (atom.length > 1 && (atom[1] === 'x' || atom[1] === 'y' || atom[1] === '#')) {
	
	              var accidentalType;
	
	              switch (atom[1]) {
	                case 'y':
	                  accidentalType = Signs.AccidentalType.Natural;
	                  break;
	                case '#':
	                  accidentalType = Signs.AccidentalType.Sharp;
	                  break;
	                default:
	                  accidentalType = Signs.AccidentalType.Flat;
	                  break;
	              }
	
	              var noteArray = [];
	              this.createNoteFromData(ctxt, ctxt.activeClef, atom, noteArray);
	              var accidental = new Signs.Accidental(noteArray[0].staffPosition, accidentalType);
	              accidental.trailingSpace = ctxt.intraNeumeSpacing * 2;
	
	              ctxt.activeClef.activeAccidental = accidental;
	
	              addNotation(accidental);
	            } else {
	
	              // looks like it's a note
	              this.createNoteFromData(ctxt, ctxt.activeClef, atom, notes);
	            }
	            break;
	        }
	      }
	
	      // finish up any remaining notes we have left
	      addNotation(null);
	
	      return notations;
	    }
	  }, {
	    key: 'createNeumesFromNotes',
	    value: function createNeumesFromNotes(ctxt, notes, finalTrailingSpace) {
	
	      var neumes = [];
	      var firstNoteIndex = 0;
	      var currNoteIndex = 0;
	
	      // here we use a simple finite state machine to create the neumes from the notes
	      // createNeume is helper function which returns the next state after a neume is created
	      // (unknownState). Each state object has a neume() function and a handle() function.
	      // neume() allows us to create the neume of the state in the event that we run out
	      // of notes. handle() gives the state an opportunity to examine the currNote and
	      // determine what to do...either transition to a different neume/state, or
	      // continue building the neume of that state. handle() returns the next state
	
	      var createNeume = function createNeume(neume, includeCurrNote) {
	        var includePrevNote = arguments.length <= 2 || arguments[2] === undefined ? true : arguments[2];
	
	
	        // add the notes to the neume
	        var lastNoteIndex;
	        if (includeCurrNote) lastNoteIndex = currNoteIndex;else if (includePrevNote) lastNoteIndex = currNoteIndex - 1;else lastNoteIndex = currNoteIndex - 2;
	
	        if (lastNoteIndex < 0) return;
	
	        while (firstNoteIndex <= lastNoteIndex) {
	          neume.addNote(notes[firstNoteIndex++]);
	        }neumes.push(neume);
	
	        if (includeCurrNote === false) {
	          currNoteIndex--;
	
	          if (includePrevNote === false) currNoteIndex--;
	
	          neume.keepWithNext = true;
	          neume.trailingSpace = ctxt.intraNeumeSpacing;
	        }
	
	        return unknownState;
	      };
	
	      var unknownState = {
	        neume: function neume() {
	          return new Neumes.Punctum();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Virga) return virgaState;else if (currNote.shape === _Exsurge3.NoteShape.Stropha) return apostrophaState;else if (currNote.shape === _Exsurge3.NoteShape.Oriscus) return oriscusState;else if (currNote.shape === _Exsurge3.NoteShape.Inclinatum) return punctaInclinataState;else if (currNote.shapeModifiers & _Exsurge3.NoteShapeModifiers.Cavum) return createNeume(new Neumes.Punctum(), true);else return punctumState;
	        }
	      };
	
	      var punctumState = {
	        neume: function neume() {
	          return new Neumes.Punctum();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.staffPosition > prevNote.staffPosition) return podatusState;else if (currNote.staffPosition < prevNote.staffPosition) {
	            if (currNote.shape === _Exsurge3.NoteShape.Inclinatum) return climacusState;else return clivisState;
	          } else return distrophaState;
	        }
	      };
	
	      var punctaInclinataState = {
	        neume: function neume() {
	          return new Neumes.PunctaInclinata();
	        },
	        handle: function handle() {
	          if (currNote.shape !== _Exsurge3.NoteShape.Inclinatum) return createNeume(new Neumes.PunctaInclinata(), false);else return punctaInclinataState;
	        }
	      };
	
	      var oriscusState = {
	        neume: function neume() {
	          return new Neumes.Oriscus();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Default) {
	
	            if (currNote.staffPosition > prevNote.staffPosition) {
	              prevNote.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Ascending;
	              return createNeume(new Neumes.PesQuassus(), true);
	            } else if (currNote.staffPosition < prevNote.staffPosition) {
	              prevNote.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Descending;
	              return createNeume(new Neumes.Clivis(), true);
	            }
	          } else
	            // stand alone oriscus
	            return createNeume(new Neumes.Oriscus(), true);
	        }
	      };
	
	      var podatusState = {
	        neume: function neume() {
	          return new Neumes.Podatus();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.staffPosition > prevNote.staffPosition) {
	
	            if (prevNote.shape === _Exsurge3.NoteShape.Oriscus) return salicusState;else return scandicusState;
	          } else if (currNote.staffPosition < prevNote.staffPosition) {
	            if (currNote.shape === _Exsurge3.NoteShape.Inclinatum) return pesSubpunctisState;else return torculusState;
	          } else return createNeume(new Neumes.Podatus(), false);
	        }
	      };
	
	      var clivisState = {
	        neume: function neume() {
	          return new Neumes.Clivis();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Default && currNote.staffPosition > prevNote.staffPosition) return porrectusState;else return createNeume(new Neumes.Clivis(), false);
	        }
	      };
	
	      var climacusState = {
	        neume: function neume() {
	          return new Neumes.Climacus();
	        },
	        handle: function handle(currNote, prevNote) {
	          if (currNote.shape !== _Exsurge3.NoteShape.Inclinatum) return createNeume(new Neumes.Climacus(), false);else return state;
	        }
	      };
	
	      var porrectusState = {
	        neume: function neume() {
	          return new Neumes.Porrectus();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Default && currNote.staffPosition < prevNote.staffPosition) return createNeume(new Neumes.PorrectusFlexus(), true);else return createNeume(new Neumes.Porrectus(), false);
	        }
	      };
	
	      var pesSubpunctisState = {
	        neume: function neume() {
	          return new Neumes.PesSubpunctis();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape !== _Exsurge3.NoteShape.Inclinatum) return createNeume(new Neumes.PesSubpunctis(), false);else return state;
	        }
	      };
	
	      var salicusState = {
	        neume: function neume() {
	          return new Neumes.Salicus();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.staffPosition < prevNote.staffPosition) return salicusFlexusState;else return createNeume(new Neumes.Salicus(), false);
	        }
	      };
	
	      var salicusFlexusState = {
	        neume: function neume() {
	          return new Neumes.SalicusFlexus();
	        },
	        handle: function handle(currNote, prevNote) {
	          return createNeume(new Neumes.SalicusFlexus(), false);
	        }
	      };
	
	      var scandicusState = {
	        neume: function neume() {
	          return new Neumes.Scandicus();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (prevNote.shape === _Exsurge3.NoteShape.Virga && currNote.shape === _Exsurge3.NoteShape.Inclinatum && currNote.staffPosition < prevNote.staffPosition) {
	            // if we get here, then it seems we have a podatus, now being followed by a climacus
	            // rather than a scandicus. react accordingly
	            return createNeume(new Neumes.Podatus(), false, false);
	          } else if (currNote.shape === _Exsurge3.NoteShape.Default && currNote.staffPosition < prevNote.staffPosition) return scandicusFlexusState;else return createNeume(new Neumes.Scandicus(), false);
	        }
	      };
	
	      var scandicusFlexusState = {
	        neume: function neume() {
	          return new Neumes.ScandicusFlexus();
	        },
	        handle: function handle(currNote, prevNote) {
	          return createNeume(new Neumes.ScandicusFlexus(), false);
	        }
	      };
	
	      var virgaState = {
	        neume: function neume() {
	          return new Neumes.Virga();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Inclinatum && currNote.staffPosition < prevNote.staffPosition) return climacusState;else if (currNote.shape === _Exsurge3.NoteShape.Virga && currNote.staffPosition === prevNote.staffPosition) return bivirgaState;else return createNeume(new Neumes.Virga(), false);
	        }
	      };
	
	      var bivirgaState = {
	        neume: function neume() {
	          return new Neumes.Bivirga();
	        },
	        handle: function handle(currNote, prevNote) {
	
	          if (currNote.shape === _Exsurge3.NoteShape.Virga && currNote.staffPosition === prevNote.staffPosition) return createNeume(new Neumes.Trivirga(), true);else return createNeume(new Neumes.Bivirga(), false);
	        }
	      };
	
	      var apostrophaState = {
	        neume: function neume() {
	          return new Neumes.Apostropha();
	        },
	        handle: function handle(currNote, prevNote) {
	          if (currNote.staffPosition === prevNote.staffPosition) return distrophaState;else return createNeume(new Neumes.Apostropha(), false);
	        }
	      };
	
	      var distrophaState = {
	        neume: function neume() {
	          return new Neumes.Distropha();
	        },
	        handle: function handle(currNote, prevNote) {
	          if (currNote.staffPosition === prevNote.staffPosition) return tristrophaState;else return createNeume(new Neumes.Apostropha(), false, false);
	        }
	      };
	
	      var tristrophaState = {
	        neume: function neume() {
	          return new Neumes.Tristropha();
	        },
	        handle: function handle(currNote, prevNote) {
	          // we only create a tristropha when the note run ends after three
	          // and the neume() function of this state is called. Otherwise
	          // we always interpret the third note to belong to the next sequence
	          // of notes.
	          //
	          // fixme: gabc allows any number of punctum/stropha in succession...
	          // is this a valid neume type? Or is it just multiple *stropha neumes
	          // in succession? Should we simplify the apostropha/distropha/
	          // tristropha classes to a generic stropha neume that can have 1 or
	          // more successive notes?
	          return createNeume(new Neumes.Distropha(), false, false);
	        }
	      };
	
	      var torculusState = {
	        neume: function neume() {
	          return new Neumes.Torculus();
	        },
	        handle: function handle(currNote, prevNote) {
	          if (currNote.shape === _Exsurge3.NoteShape.Default && currNote.staffPosition > prevNote.staffPosition) return torculusResupinusState;else return createNeume(new Neumes.Torculus(), false);
	        }
	      };
	
	      var torculusResupinusState = {
	        neume: function neume() {
	          return new Neumes.TorculusResupinus();
	        },
	        handle: function handle(currNote, prevNote) {
	          if (currNote.shape === _Exsurge3.NoteShape.Default && currNote.staffPosition < prevNote.staffPosition) return createNeume(new Neumes.TorculusResupinusFlexus(), true);else return createNeume(new Neumes.TorculusResupinus(), false);
	        }
	      };
	
	      var state = unknownState;
	
	      while (currNoteIndex < notes.length) {
	
	        var prevNote = currNoteIndex > 0 ? notes[currNoteIndex - 1] : null;
	        var currNote = notes[currNoteIndex];
	
	        state = state.handle(currNote, prevNote);
	
	        // if we are on the last note, then try to create a neume if we need to.
	        if (currNoteIndex === notes.length - 1 && state !== unknownState) createNeume(state.neume(), true);
	
	        currNoteIndex++;
	      }
	
	      if (neumes.length > 0) {
	        if (finalTrailingSpace >= 0) {
	          neumes[neumes.length - 1].trailingSpace = finalTrailingSpace;
	
	          if (finalTrailingSpace > ctxt.intraNeumeSpacing) neumes[neumes.length - 1].keepWithNext = false;else neumes[neumes.length - 1].keepWithNext = true;
	        }
	      }
	
	      return neumes;
	    }
	
	    // appends any notes created to the notes array argument
	
	  }, {
	    key: 'createNoteFromData',
	    value: function createNoteFromData(ctxt, clef, data, notes) {
	
	      var note = new _Exsurge3.Note();
	
	      if (data.length < 1) throw 'Invalid note data: ' + data;
	
	      if (data[0] === '-') {
	        // liquescent initio debilis
	        note.liquescent = _Exsurge3.LiquescentType.InitioDebilis;
	        data = data.substring(1);
	      }
	
	      if (data.length < 1) throw 'Invalid note data: ' + data;
	
	      // the next char is always the pitch
	      var pitch = this.gabcHeightToExsurgePitch(clef, data[0]);
	
	      if (data[0] === data[0].toUpperCase()) note.shape = _Exsurge3.NoteShape.Inclinatum;
	
	      note.staffPosition = this.gabcHeightToExsurgeHeight(data[0]);
	      note.pitch = pitch;
	
	      var mark;
	      var j;
	
	      var episemaNoteIndex = notes.length;
	      var episemaNote = note;
	
	      // process the modifiers
	      for (var i = 1; i < data.length; i++) {
	
	        var c = data[i];
	        var lookahead = '\0';
	
	        var haveLookahead = i + 1 < data.length;
	        if (haveLookahead) lookahead = data[i + 1];
	
	        switch (c) {
	
	          // rhythmic markings
	          case '.':
	
	            mark = null;
	
	            // gabc supports putting up to two morae on each note, by repeating the
	            // period. here, we check to see if we've already created a mora for the
	            // note, and if so, we simply force the second one to have an Above
	            // position hint. if a user decides to try to put position indicators
	            // on the double morae (such as 1 or 2), then really the behavior is
	            // not defined by gabc, so it's on the user to figure it out.
	            if (note.morae.length > 0) {
	              // if we already have one mora, then create another but force a
	              // an alternative positionHint
	              haveLookahead = true;
	              if (Math.abs(note.staffPosition) % 2 === 0) lookahead = '1';else lookahead = '0';
	            }
	
	            mark = new Markings.Mora(ctxt, note);
	            if (haveLookahead && lookahead === '1') mark.positionHint = Markings.MarkingPositionHint.Above;else if (haveLookahead && lookahead === '0') mark.positionHint = Markings.MarkingPositionHint.Below;
	
	            note.morae.push(mark);
	            break;
	
	          case '_':
	
	            var episemaHadModifier = false;
	
	            mark = new Markings.HorizontalEpisema(episemaNote);
	            while (haveLookahead) {
	
	              if (lookahead === '0') mark.positionHint = Markings.MarkingPositionHint.Below;else if (lookahead === '1') mark.positionHint = Markings.MarkingPositionHint.Above;else if (lookahead === '2') mark.terminating = true; // episema terminates
	              else if (lookahead === '3') mark.alignment = Markings.HorizontalEpisemaAlignment.Left;else if (lookahead === '4') mark.alignment = Markings.HorizontalEpisemaAlignment.Center;else if (lookahead === '5') mark.alignment = Markings.HorizontalEpisemaAlignment.Right;else break;
	
	              // the gabc definition for epismata is so convoluted...
	              // - double underscores create epismata over multiple notes.
	              // - unless the _ has a 0, 1, 3, 4, or 5 modifier, which means
	              //   another underscore puts a second epismata on the same note
	              // - (when there's a 2 lookahead, then this is treated as an
	              //   unmodified underscore, so another underscore would be
	              //   added to previous notes
	              if (mark.alignment !== Markings.HorizontalEpisemaAlignment.Default && mark.positionHint !== Markings.MarkingPositionHint.Below) episemaHadModifier = true;
	
	              i++;
	              haveLookahead = i + 1 < data.length;
	
	              if (haveLookahead) lookahead = data[i + 1];
	            }
	
	            // since gabc allows consecutive underscores which is a shortcut to
	            // apply the epismata to previous notes, we keep track of that here
	            // in order to add the new episema to the correct note.
	
	            if (episemaNote) episemaNote.epismata.push(mark);
	
	            if (episemaNote === note && episemaHadModifier) episemaNote = note;else if (episemaNoteIndex >= 0 && notes.length > 0) episemaNote = notes[--episemaNoteIndex];
	
	            break;
	
	          case '\'':
	            mark = new Markings.Ictus(ctxt, note);
	            if (haveLookahead && lookahead === '1') mark.positionHint = Markings.MarkingPositionHint.Above;else if (haveLookahead && lookahead === '0') mark.positionHint = Markings.MarkingPositionHint.Below;
	
	            note.ictus = mark;
	            break;
	
	          //note shapes
	          case 'r':
	            if (haveLookahead && lookahead === '1') {
	              note.acuteAccent = new Markings.AcuteAccent(ctxt, note);
	              i++;
	            } else note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Cavum;
	            break;
	
	          case 's':
	
	            if (note.shape === _Exsurge3.NoteShape.Stropha) {
	              // if we're already a stropha, that means this is gabc's
	              // quick stropha feature (e.g., gsss). create a new note
	              notes.push(note);
	              note = new _Exsurge3.Note();
	              episemaNoteIndex++; // since a new note was added, increase the index here
	            }
	
	            note.shape = _Exsurge3.NoteShape.Stropha;
	            break;
	
	          case 'v':
	
	            if (note.shape === _Exsurge3.NoteShape.Virga) {
	              // if we're already a stropha, that means this is gabc's
	              // quick virga feature (e.g., gvvv). create a new note
	              notes.push(note);
	              note = new _Exsurge3.Note();
	              episemaNoteIndex++; // since a new note was added, increase the index here
	            }
	
	            note.shape = _Exsurge3.NoteShape.Virga;
	            break;
	
	          case 'w':
	            note.shape = _Exsurge3.NoteShape.Quilisma;
	            break;
	
	          case 'o':
	            note.shape = _Exsurge3.NoteShape.Oriscus;
	            if (haveLookahead && lookahead === '<') {
	              note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Ascending;
	              i++;
	            } else if (haveLookahead && lookahead === '>') {
	              note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Descending;
	              i++;
	            }
	            break;
	
	          case 'O':
	            note.shape = _Exsurge3.NoteShape.Oriscus;
	            if (haveLookahead && lookahead === '<') {
	              note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Ascending | _Exsurge3.NoteShapeModifiers.Stemmed;
	              i++;
	            } else if (haveLookahead && lookahead === '>') {
	              note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Descending | _Exsurge3.NoteShapeModifiers.Stemmed;
	              i++;
	            } else note.shapeModifiers |= _Exsurge3.NoteShapeModifiers.Stemmed;
	            break;
	
	          // liquescents
	          case '~':
	            if (note.shape === _Exsurge3.NoteShape.Inclinatum) note.liquescent |= _Exsurge3.LiquescentType.Small;else if (note.shape === _Exsurge3.NoteShape.Oriscus) note.liquescent |= _Exsurge3.LiquescentType.Large;else note.liquescent |= _Exsurge3.LiquescentType.Small;
	            break;
	          case '<':
	            note.liquescent |= _Exsurge3.LiquescentType.Ascending;
	            break;
	          case '>':
	            note.liquescent |= _Exsurge3.LiquescentType.Descending;
	            break;
	
	          // accidentals
	          case 'x':
	            if (note.pitch.step === _Exsurge.Step.Mi) note.pitch.step = _Exsurge.Step.Me;else if (note.pitch.step === _Exsurge.Step.Ti) note.pitch.step = _Exsurge.Step.Te;
	            break;
	          case 'y':
	            if (note.pitch.step === _Exsurge.Step.Te) note.pitch.step = _Exsurge.Step.Ti;else if (note.pitch.step === _Exsurge.Step.Me) note.pitch.step = _Exsurge.Step.Mi;else if (note.pitch.step === _Exsurge.Step.Du) note.pitch.step = _Exsurge.Step.Do;else if (note.pitch.step === _Exsurge.Step.Fu) note.pitch.step = _Exsurge.Step.Fa;
	            break;
	          case '#':
	            if (note.pitch.step === _Exsurge.Step.Do) note.pitch.step = _Exsurge.Step.Du;else if (note.pitch.step === _Exsurge.Step.Fa) note.pitch.step = _Exsurge.Step.Fu;
	            break;
	
	          // gabc special item groups
	          case '[':
	            // read in the whole group and parse it
	            var startIndex = ++i;
	            while (i < data.length && data[i] !== ']') {
	              i++;
	            }this.processInstructionForNote(ctxt, note, data.substring(startIndex, i));
	            break;
	        }
	      }
	
	      notes.push(note);
	    }
	
	    // an instruction in this context is referring to a special gabc coding found after
	    // notes between ['s and ]'s. choral signs and braces fall into this
	    // category.
	    //
	    // currently only brace instructions are supported here!
	
	  }, {
	    key: 'processInstructionForNote',
	    value: function processInstructionForNote(ctxt, note, instruction) {
	
	      var results = instruction.match(__braceSpecRegex);
	
	      if (results === null) return;
	
	      // see the comments at the definition of __braceSpecRegex for the
	      // capturing groups
	      var above = results[1] === 'o';
	      var shape = Markings.BraceShape.CurlyBrace; // default
	
	      switch (results[2]) {
	        case 'b':
	          shape = Markings.BraceShape.RoundBrace;
	          break;
	        case 'cb':
	          shape = Markings.BraceShape.CurlyBrace;
	          break;
	        case 'cba':
	          shape = Markings.BraceShape.AccentedCurlyBrace;
	          break;
	      }
	
	      var attachmentPoint = results[3] === '0' ? Markings.BraceAttachment.Left : Markings.BraceAttachment.Right;
	      var brace = null;
	      var type;
	
	      if (results[4] === '{') note.braceStart = new Markings.BracePoint(note, above, shape, attachmentPoint);else note.braceEnd = new Markings.BracePoint(note, above, shape, attachmentPoint);
	    }
	
	    // takes raw gabc text source and parses it into words. For example, passing
	    // in a string of "me(f.) (,) ma(fff)num(d!ewf) tu(fgF'E)am,(f.)" would return
	    // an array of four strings: ["me(f.)", "(,)", "ma(fff)num(d!ewf)", "tu(fgF'E)am,(f.)"]
	
	  }, {
	    key: 'splitWords',
	    value: function splitWords(gabcNotations) {
	      // split the notations on whitespace boundaries, as long as the space
	      // immediately follows a set of parentheses. Prior to doing that, we replace
	      // all whitespace with spaces, which prevents tabs and newlines from ending
	      // up in the notation data.
	      gabcNotations = gabcNotations.trim().replace(/\s/g, ' ').replace(/\) (?=[^\)]*(?:\(|$))/g, ')\n');
	      return gabcNotations.split(/\n/g);
	    }
	  }, {
	    key: 'parseSource',
	    value: function parseSource(gabcSource) {
	      return this.parseWords(this.splitWords(gabcSource));
	    }
	
	    // gabcWords is an array of strings, e.g., the result of splitWords above
	
	  }, {
	    key: 'parseWords',
	    value: function parseWords(gabcWords) {
	      var words = [];
	
	      for (var i = 0; i < gabcWords.length; i++) {
	        words.push(this.parseWord(gabcWords[i]));
	      }return words;
	    }
	
	    // returns an array of objects, each of which has the following properties
	    //  - notations (string)
	    //  - lyrics (array of strings)
	
	  }, {
	    key: 'parseWord',
	    value: function parseWord(gabcWord) {
	
	      var syllables = [];
	      var matches = [];
	
	      while (match = __syllablesRegex.exec(gabcWord)) {
	        matches.push(match);
	      }for (var j = 0; j < matches.length; j++) {
	        var match = matches[j];
	
	        var lyrics = match[1].trim().split('|');
	        var notations = match[2];
	
	        syllables.push({
	          notations: notations,
	          lyrics: lyrics
	        });
	      }
	
	      return syllables;
	    }
	
	    // returns pitch
	
	  }, {
	    key: 'gabcHeightToExsurgeHeight',
	    value: function gabcHeightToExsurgeHeight(gabcHeight) {
	      return gabcHeight.toLowerCase().charCodeAt(0) - 'a'.charCodeAt(0) - 6;
	    }
	
	    // returns pitch
	
	  }, {
	    key: 'gabcHeightToExsurgePitch',
	    value: function gabcHeightToExsurgePitch(clef, gabcHeight) {
	      var exsurgeHeight = this.gabcHeightToExsurgeHeight(gabcHeight);
	
	      var pitch = clef.staffPositionToPitch(exsurgeHeight);
	
	      if (clef.activeAccidental !== null) clef.activeAccidental.applyToPitch(pitch);
	
	      return pitch;
	    }
	  }]);
	
	  return Gabc;
	}();

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.Virga = exports.Tristropha = exports.TorculusResupinusFlexus = exports.TorculusResupinus = exports.Torculus = exports.ScandicusFlexus = exports.Scandicus = exports.SalicusFlexus = exports.Salicus = exports.Punctum = exports.PunctaInclinata = exports.PorrectusFlexus = exports.Porrectus = exports.Podatus = exports.PesSubpunctis = exports.PesQuassus = exports.Oriscus = exports.Distropha = exports.Clivis = exports.Climacus = exports.Trivirga = exports.Bivirga = exports.Apostropha = exports.Neume = undefined;
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }(); //
	// Author(s):
	// Fr. Matthew Spencer, OSJ <mspencer@osjusa.org>
	//
	// Copyright (c) 2008-2016 Fr. Matthew Spencer, OSJ
	//
	// Permission is hereby granted, free of charge, to any person obtaining a copy
	// of this software and associated documentation files (the "Software"), to deal
	// in the Software without restriction, including without limitation the rights
	// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	// copies of the Software, and to permit persons to whom the Software is
	// furnished to do so, subject to the following conditions:
	//
	// The above copyright notice and this permission notice shall be included in
	// all copies or substantial portions of the Software.
	//
	// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	// THE SOFTWARE.
	//
	
	var _Exsurge = __webpack_require__(1);
	
	var Exsurge = _interopRequireWildcard(_Exsurge);
	
	var _Exsurge2 = __webpack_require__(4);
	
	var _Exsurge3 = __webpack_require__(6);
	
	var _ExsurgeChant = __webpack_require__(9);
	
	var _Exsurge4 = __webpack_require__(3);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	var NeumeBuilder = function () {
	  function NeumeBuilder(ctxt, neume) {
	    var startingX = arguments.length <= 2 || arguments[2] === undefined ? 0 : arguments[2];
	
	    _classCallCheck(this, NeumeBuilder);
	
	    this.ctxt = ctxt;
	    this.neume = neume;
	    this.x = startingX;
	    this.lastNote = null;
	    this.lineIsHanging = false;
	  }
	
	  // used to start a hanging line on the left of the next note
	
	
	  _createClass(NeumeBuilder, [{
	    key: 'lineFrom',
	    value: function lineFrom(note) {
	      this.lastNote = note;
	      this.lineIsHanging = true;
	
	      return this;
	    }
	
	    // add a note, with a connecting line on the left if we have one
	
	  }, {
	    key: 'noteAt',
	    value: function noteAt(note, glyph) {
	      var withLineTo = arguments.length <= 2 || arguments[2] === undefined ? true : arguments[2];
	
	
	      if (!note) throw "NeumeBuilder.noteAt: note must be a valid note";
	
	      if (!glyph) throw "NeumeBuilder.noteAt: glyph must be a valid glyph code";
	
	      note.setGlyph(this.ctxt, glyph);
	      var noteAlignsRight = note.glyphVisualizer.align === "right";
	
	      var needsLine = withLineTo && this.lastNote !== null && (this.lineIsHanging || this.lastNote.glyphVisualizer.align === 'right' || Math.abs(this.lastNote.staffPosition - note.staffPosition) > 1);
	
	      if (needsLine) {
	        var line = new _Exsurge2.NeumeLineVisualizer(this.ctxt, this.lastNote, note, this.lineIsHanging);
	        this.neume.addVisualizer(line);
	        line.bounds.x = Math.max(0, this.x - line.bounds.width);
	
	        if (!noteAlignsRight) this.x = line.bounds.x;
	      }
	
	      // if this is the first note of a right aligned glyph (probably an initio debilis),
	      // then there's nothing to worry about. but if it's not then first, then this
	      // subtraction will right align it visually
	      if (noteAlignsRight && this.lastNote) note.bounds.x = this.x - note.bounds.width;else {
	        note.bounds.x = this.x;
	        this.x += note.bounds.width;
	      }
	
	      this.neume.addVisualizer(note);
	
	      this.lastNote = note;
	      this.lineIsHanging = false;
	
	      return this;
	    }
	
	    // a special form of noteAdd that creates a virga
	    // uses a punctum cuadratum and a line rather than the virga glyphs
	
	  }, {
	    key: 'virgaAt',
	    value: function virgaAt(note) {
	      var withLineTo = arguments.length <= 1 || arguments[1] === undefined ? true : arguments[1];
	
	
	      // add the punctum for the virga
	      this.noteAt(note, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      // add a line for the virga
	      var line = new _Exsurge2.VirgaLineVisualizer(this.ctxt, note);
	      this.x -= line.bounds.width;
	      line.bounds.x = this.x;
	      this.neume.addVisualizer(line);
	
	      this.lastNote = note;
	      this.lineIsHanging = false;
	
	      return this;
	    }
	  }, {
	    key: 'advanceBy',
	    value: function advanceBy(x) {
	      this.lastNote = null;
	      this.lineIsHanging = false;
	
	      this.x += x;
	
	      return this;
	    }
	
	    // for terminating hanging lines with no lower notes
	
	  }, {
	    key: 'withLineEndingAt',
	    value: function withLineEndingAt(note) {
	
	      if (this.lastNote === null) return;
	
	      var line = new _Exsurge2.NeumeLineVisualizer(this.ctxt, this.lastNote, note, true);
	      this.neume.addVisualizer(line);
	      this.x -= line.bounds.width;
	      line.bounds.x = this.x;
	
	      this.neume.addVisualizer(line);
	
	      this.lastNote = note;
	
	      return this;
	    }
	  }, {
	    key: 'withPodatus',
	    value: function withPodatus(lowerNote, upperNote) {
	
	      var upperGlyph;
	      var lowerGlyph;
	
	      if (lowerNote.liquescent === _Exsurge3.LiquescentType.InitioDebilis) {
	
	        // liquescent upper note or not?
	        if (upperNote.liquescent === _Exsurge3.LiquescentType.None) upperGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;else upperGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	
	        lowerGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (upperNote.liquescent & _Exsurge3.LiquescentType.Small) {
	        lowerGlyph = _Exsurge2.GlyphCode.BeginningAscLiquescent;
	        upperGlyph = _Exsurge2.GlyphCode.TerminatingAscLiquescent;
	      } else if (upperNote.liquescent & _Exsurge3.LiquescentType.Ascending) {
	        lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	        upperGlyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;
	      } else if (upperNote.liquescent & _Exsurge3.LiquescentType.Descending) {
	        lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	        upperGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	      } else {
	        // standard shape
	        lowerGlyph = _Exsurge2.GlyphCode.PodatusLower;
	        upperGlyph = _Exsurge2.GlyphCode.PodatusUpper;
	      }
	
	      // allow a quilisma pes
	      if (lowerNote.shape === _Exsurge3.NoteShape.Quilisma) lowerGlyph = _Exsurge2.GlyphCode.Quilisma;
	
	      this.noteAt(lowerNote, lowerGlyph).noteAt(upperNote, upperGlyph);
	
	      // make sure we don't have lines connected to the podatus
	      this.lastNote = null;
	
	      return this;
	    }
	  }, {
	    key: 'withClivis',
	    value: function withClivis(upper, lower) {
	
	      var line;
	
	      var upperGlyph;
	      var lowerGlyph;
	
	      if (upper.shape === _Exsurge3.NoteShape.Oriscus) this.noteAt(upper, _Exsurge2.GlyphCode.OriscusDes, false);else this.lineFrom(lower).noteAt(upper, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      if (lower.liquescent & _Exsurge3.LiquescentType.Small) {
	        lowerGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (lower.liquescent === _Exsurge3.LiquescentType.Ascending) lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (lower.liquescent === _Exsurge3.LiquescentType.Descending) lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      this.noteAt(lower, lowerGlyph);
	
	      // make sure we don't have lines connected to the clivis
	      this.lastNote = null;
	
	      return this;
	    }
	
	    // lays out a sequence of notes that are inclinati (e.g., climacus, pes subpunctis)
	
	  }, {
	    key: 'withInclinati',
	    value: function withInclinati(notes) {
	
	      var staffPosition = notes[0].staffPosition,
	          prevStaffPosition = notes[0].staffPosition;
	
	      // it is important to advance by the width of the inclinatum glyph itself
	      // rather than by individual note widths, so that any liquescents are spaced
	      // the same as non-liquscents
	      var advanceWidth = _Exsurge4.Glyphs.PunctumInclinatum.bounds.width * this.ctxt.glyphScaling;
	
	      // now add all the punctum inclinati
	      for (var i = 0; i < notes.length; i++, prevStaffPosition = staffPosition) {
	        var note = notes[i];
	
	        if (note.liquescent & _Exsurge3.LiquescentType.Small) note.setGlyph(this.ctxt, _Exsurge2.GlyphCode.PunctumInclinatumLiquescent);else if (note.liquescent & _Exsurge3.LiquescentType.Large)
	          // fixme: is the large inclinatum liquescent the same as the apostropha?
	          note.setGlyph(this.ctxt, _Exsurge2.GlyphCode.Stropha);else
	          // fixme: some climaci in the new chant books end with a punctum quadratum
	          // (see, for example, the antiphon "Sancta Maria" for October 7).
	          note.setGlyph(this.ctxt, _Exsurge2.GlyphCode.PunctumInclinatum);
	
	        staffPosition = note.staffPosition;
	
	        // fixme: how do these calculations look for puncti inclinati based on staff position offsets?
	        var multiple;
	        switch (Math.abs(prevStaffPosition - staffPosition)) {
	          case 0:
	            multiple = 1.1;
	            break;
	          case 1:
	            multiple = 0.8;
	            break;
	          default:
	            multiple = 1.2;
	            break;
	        }
	
	        if (i > 0) this.x += advanceWidth * multiple;
	
	        note.bounds.x = this.x;
	
	        this.neume.addVisualizer(note);
	      }
	
	      return this;
	    }
	  }, {
	    key: 'withPorrectusSwash',
	    value: function withPorrectusSwash(start, end) {
	
	      var needsLine = this.lastNote !== null && (this.lineIsHanging || this.lastNote.glyphVisualizer.align === 'right' || Math.abs(this.lastNote.staffPosition - start.staffPosition) > 1);
	
	      if (needsLine) {
	        var line = new _Exsurge2.NeumeLineVisualizer(this.ctxt, this.lastNote, start, this.lineIsHanging);
	        this.x = Math.max(0, this.x - line.bounds.width);
	        line.bounds.x = this.x;
	        this.neume.addVisualizer(line);
	      }
	
	      var glyph;
	
	      switch (start.staffPosition - end.staffPosition) {
	        case 1:
	          glyph = _Exsurge2.GlyphCode.Porrectus1;
	          break;
	        case 2:
	          glyph = _Exsurge2.GlyphCode.Porrectus2;
	          break;
	        case 3:
	          glyph = _Exsurge2.GlyphCode.Porrectus3;
	          break;
	        case 4:
	          glyph = _Exsurge2.GlyphCode.Porrectus4;
	          break;
	        default:
	          // fixme: should we generate an error here?
	          glyph = _Exsurge2.GlyphCode.None;
	          break;
	      }
	
	      start.setGlyph(this.ctxt, glyph);
	      start.bounds.x = this.x;
	
	      // the second glyph does not draw anything, but it still has logical importance for the editing
	      // environment...it can respond to changes which will then change the swash glyph of the first.
	      end.setGlyph(this.ctxt, _Exsurge2.GlyphCode.None);
	
	      this.x = start.bounds.right();
	      end.bounds.x = this.x - end.bounds.width;
	
	      this.neume.addVisualizer(start);
	      this.neume.addVisualizer(end);
	
	      this.lastNote = end;
	      this.lineIsHanging = false;
	
	      return this;
	    }
	  }]);
	
	  return NeumeBuilder;
	}();
	
	/*
	 * Neumes base class
	 */
	
	
	var Neume = exports.Neume = function (_ChantNotationElement) {
	  _inherits(Neume, _ChantNotationElement);
	
	  function Neume() {
	    var notes = arguments.length <= 0 || arguments[0] === undefined ? [] : arguments[0];
	
	    _classCallCheck(this, Neume);
	
	    var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(Neume).call(this));
	
	    _this.isNeume = true; // poor man's reflection
	    _this.notes = notes;
	
	    for (var i = 0; i < notes.length; i++) {
	      notes[i].neume = _this;
	    }return _this;
	  }
	
	  _createClass(Neume, [{
	    key: 'addNote',
	    value: function addNote(note) {
	      note.neume = this;
	      this.notes.push(note);
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Neume.prototype), 'performLayout', this).call(this, ctxt);
	    }
	  }, {
	    key: 'finishLayout',
	    value: function finishLayout(ctxt) {
	
	      // allow subclasses an opportunity to position their own markings...
	      this.positionMarkings();
	
	      // layout the markings of the notes
	      for (var i = 0; i < this.notes.length; i++) {
	        var note = this.notes[i];
	        var j;
	
	        for (j = 0; j < note.epismata.length; j++) {
	          note.epismata[j].performLayout(ctxt);
	          this.addVisualizer(note.epismata[j]);
	        }
	
	        for (j = 0; j < note.morae.length; j++) {
	          note.morae[j].performLayout(ctxt);
	          this.addVisualizer(note.morae[j]);
	        }
	
	        // if the note has an ictus, then add it here
	        if (note.ictus) {
	          note.ictus.performLayout(ctxt);
	          this.addVisualizer(note.ictus);
	        }
	
	        if (note.acuteAccent) {
	          note.acuteAccent.performLayout(ctxt);
	          this.addVisualizer(note.acuteAccent);
	        }
	
	        // braces are handled by the chant line, so we don't mess with them here
	        // this is because brace size depends on chant line logic (neume spacing,
	        // justification, etc.) so they are considered chant line level
	        // markings rather than note level markings
	      }
	
	      this.origin.x = this.notes[0].origin.x;
	      this.origin.y = this.notes[0].origin.y;
	
	      _get(Object.getPrototypeOf(Neume.prototype), 'finishLayout', this).call(this, ctxt);
	    }
	  }, {
	    key: 'resetDependencies',
	    value: function resetDependencies() {}
	  }, {
	    key: 'build',
	    value: function build(ctxt) {
	      return new NeumeBuilder(ctxt, this);
	    }
	
	    // subclasses can override this in order to correctly place markings in a neume specific way
	
	  }, {
	    key: 'positionMarkings',
	    value: function positionMarkings() {}
	  }]);
	
	  return Neume;
	}(_Exsurge2.ChantNotationElement);
	
	/*
	 * Apostropha
	 */
	
	
	var Apostropha = exports.Apostropha = function (_Neume) {
	  _inherits(Apostropha, _Neume);
	
	  function Apostropha() {
	    _classCallCheck(this, Apostropha);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Apostropha).apply(this, arguments));
	  }
	
	  _createClass(Apostropha, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	      // logic here is this: if first episema is default position, place it above.
	      // then place the second one (if there is one) opposite of the first.
	      for (var i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = positionHint;else positionHint = this.notes[0].epismata[i].positionHint;
	
	        // now place the next one in the opposite position
	        positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Apostropha.prototype), 'performLayout', this).call(this, ctxt);
	
	      var y = ctxt.calculateHeightFromStaffPosition(4);
	
	      this.build(ctxt).noteAt(this.notes[0], Apostropha.getNoteGlyphCode(this.notes[0]));
	
	      this.finishLayout(ctxt);
	    }
	  }], [{
	    key: 'getNoteGlyphCode',
	    value: function getNoteGlyphCode(note) {
	
	      if (note.shape === _Exsurge3.NoteShape.Stropha) return _Exsurge2.GlyphCode.Stropha;
	
	      if (note.liquescent !== _Exsurge3.LiquescentType.None) return _Exsurge2.GlyphCode.StrophaLiquescent;
	
	      if (note.shapeModifiers & _Exsurge3.NoteShapeModifiers.Cavum) return _Exsurge2.GlyphCode.PunctumCavum;
	
	      return _Exsurge2.GlyphCode.PunctumQuadratum;
	    }
	  }]);
	
	  return Apostropha;
	}(Neume);
	
	/*
	 * Bivirga
	 *
	 * For simplicity in implementation, Bivirga's have two notes in the object
	 * structure. These technically must be the same pitch though.
	 */
	
	
	var Bivirga = exports.Bivirga = function (_Neume2) {
	  _inherits(Bivirga, _Neume2);
	
	  function Bivirga() {
	    _classCallCheck(this, Bivirga);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Bivirga).apply(this, arguments));
	  }
	
	  _createClass(Bivirga, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i, j;
	
	      for (i = 0; i < this.notes.length; i++) {
	        var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	        // logic here is this: if first episema is default position, place it above.
	        // then place the second one (if there is one) opposite of the first.
	        for (j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = positionHint;else positionHint = this.notes[i].epismata[j].positionHint;
	
	          // now place the next one in the opposite position
	          positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Bivirga.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).virgaAt(this.notes[0]).advanceBy(ctxt.intraNeumeSpacing).virgaAt(this.notes[1]);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Bivirga;
	}(Neume);
	
	/*
	 * Trivirga
	 *
	 * For simplicity in implementation, Trivirga's have three notes in the object
	 * structure. These technically must be the same pitch though.
	 */
	
	
	var Trivirga = exports.Trivirga = function (_Neume3) {
	  _inherits(Trivirga, _Neume3);
	
	  function Trivirga() {
	    _classCallCheck(this, Trivirga);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Trivirga).apply(this, arguments));
	  }
	
	  _createClass(Trivirga, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i, j;
	
	      for (i = 0; i < this.notes.length; i++) {
	        var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	        // logic here is this: if first episema is default position, place it above.
	        // then place the second one (if there is one) opposite of the first.
	        for (j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = positionHint;else positionHint = this.notes[i].epismata[j].positionHint;
	
	          // now place the next one in the opposite position
	          positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Trivirga.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).virgaAt(this.notes[0]).advanceBy(ctxt.intraNeumeSpacing).virgaAt(this.notes[1]).advanceBy(ctxt.intraNeumeSpacing).virgaAt(this.notes[2]);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Trivirga;
	}(Neume);
	
	/*
	 * Climacus
	 */
	
	
	var Climacus = exports.Climacus = function (_Neume4) {
	  _inherits(Climacus, _Neume4);
	
	  function Climacus() {
	    _classCallCheck(this, Climacus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Climacus).apply(this, arguments));
	  }
	
	  _createClass(Climacus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	
	      for (var i = 0; i < this.notes.length; i++) {
	        for (var j = 0; j < this.notes[i].epismata.length; j++) {
	          var mark = this.notes[i].epismata[j];
	
	          if (mark.positionHint === _ExsurgeChant.MarkingPositionHint.Default) mark.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Climacus.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).virgaAt(this.notes[0]).advanceBy(ctxt.intraNeumeSpacing / 2).withInclinati(this.notes.slice(1));
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Climacus;
	}(Neume);
	
	/*
	 * Clivis
	 */
	
	
	var Clivis = exports.Clivis = function (_Neume5) {
	  _inherits(Clivis, _Neume5);
	
	  function Clivis() {
	    _classCallCheck(this, Clivis);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Clivis).apply(this, arguments));
	  }
	
	  _createClass(Clivis, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	
	      var hasLowerMora = false;
	      var mark, i;
	
	      // 1. morae need to be lined up if both notes have morae
	      // 2. like the podatus, mora on lower note needs to below
	      //    under certain circumstances
	      for (i = 0; i < this.notes[1].morae.length; i++) {
	        mark = this.notes[1].morae[i];
	
	        if (this.notes[0].staffPosition - this.notes[1].staffPosition === 1 && Math.abs(this.notes[1].staffPosition % 2) === 1) mark.positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[0].morae.length; i++) {
	
	        if (hasLowerMora) {
	          mark = this.notes[0].morae[i];
	          mark.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	          mark.horizontalOffset += this.notes[1].bounds.right() - this.notes[0].bounds.right();
	        }
	      }
	
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        mark = this.notes[0].epismata[i];
	
	        if (mark.positionHint === _ExsurgeChant.MarkingPositionHint.Default) mark.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        mark = this.notes[1].epismata[i];
	
	        if (mark.positionHint === _ExsurgeChant.MarkingPositionHint.Default) mark.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Clivis.prototype), 'performLayout', this).call(this, ctxt);
	
	      var upper = this.notes[0];
	      var lower = this.notes[1];
	
	      this.build(ctxt).withClivis(upper, lower);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Clivis;
	}(Neume);
	
	/*
	 * Distropha
	 *
	 * For simplicity in implementation, Distropha's have two notes in the object
	 * structure. These technically must be the same pitch though (like Bivirga).
	 */
	
	
	var Distropha = exports.Distropha = function (_Neume6) {
	  _inherits(Distropha, _Neume6);
	
	  function Distropha() {
	    _classCallCheck(this, Distropha);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Distropha).apply(this, arguments));
	  }
	
	  _createClass(Distropha, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	
	      for (var i = 0; i < this.notes.length; i++) {
	        var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	        // logic here is this: if first episema is default position, place it above.
	        // then place the second one (if there is one) opposite of the first.
	        for (var j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = positionHint;else positionHint = this.notes[i].epismata[j].positionHint;
	
	          // now place the next one in the opposite position
	          positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Distropha.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).noteAt(this.notes[0], Apostropha.getNoteGlyphCode(this.notes[0])).advanceBy(ctxt.intraNeumeSpacing).noteAt(this.notes[1], Apostropha.getNoteGlyphCode(this.notes[1]));
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Distropha;
	}(Neume);
	
	/*
	 * Oriscus
	 */
	
	
	var Oriscus = exports.Oriscus = function (_Neume7) {
	  _inherits(Oriscus, _Neume7);
	
	  function Oriscus() {
	    _classCallCheck(this, Oriscus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Oriscus).apply(this, arguments));
	  }
	
	  _createClass(Oriscus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	      // logic here is this: if first episema is default position, place it above.
	      // then place the second one (if there is one) opposite of the first.
	      for (var i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = positionHint;else positionHint = this.notes[0].epismata[i].positionHint;
	
	        // now place the next one in the opposite position
	        positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Oriscus.prototype), 'performLayout', this).call(this, ctxt);
	
	      // determine the glyph to use
	      var note = this.notes[0];
	      var glyph;
	
	      if (note.liquescent !== _Exsurge3.LiquescentType.None) {
	        glyph = _Exsurge2.GlyphCode.OriscusLiquescent;
	      } else {
	        if (note.shapeModifiers & _Exsurge3.NoteShapeModifiers.Ascending) glyph = _Exsurge2.GlyphCode.OriscusAsc;else if (note.shapeModifiers & _Exsurge3.NoteShapeModifiers.Descending) glyph = _Exsurge2.GlyphCode.OriscusDes;else {
	          // by default we take the descending form, unless we can figure out by a lookahead here
	          glyph = _Exsurge2.GlyphCode.OriscusDes;
	
	          // try to find a neume following this one
	          var neume = ctxt.findNextNeume();
	
	          if (neume) {
	            var nextNoteStaffPosition = ctxt.activeClef.pitchToStaffPosition(neume.notes[0].pitch);
	
	            if (nextNoteStaffPosition > note.staffPosition) glyph = _Exsurge2.GlyphCode.OriscusAsc;
	          }
	        }
	      }
	
	      this.build(ctxt).noteAt(note, glyph);
	
	      this.finishLayout(ctxt);
	    }
	  }, {
	    key: 'resetDependencies',
	    value: function resetDependencies() {
	
	      // a single oriscus tries to automatically use the right direction
	      // based on the following neumes. if we don't have a manually designated
	      // direction, then we reset our layout so that we can try to guess it
	      // at next layout phase.
	      if (this.notes[0].shapeModifiers & _Exsurge3.NoteShapeModifiers.Ascending || this.notes[0].shapeModifiers & _Exsurge3.NoteShapeModifiers.Descending) return;
	
	      this.needsLayout = true;
	    }
	  }]);
	
	  return Oriscus;
	}(Neume);
	
	/*
	 * PesQuassus
	 */
	
	
	var PesQuassus = exports.PesQuassus = function (_Neume8) {
	  _inherits(PesQuassus, _Neume8);
	
	  function PesQuassus() {
	    _classCallCheck(this, PesQuassus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(PesQuassus).apply(this, arguments));
	  }
	
	  _createClass(PesQuassus, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(PesQuassus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var lower = this.notes[0];
	      var upper = this.notes[1];
	
	      var lowerGlyph, upperGlyph;
	
	      var lowerStaffPos = lower.staffPosition;
	      var upperStaffPos = upper.staffPosition;
	
	      if (lower.shape === _Exsurge3.NoteShape.Oriscus) lowerGlyph = _Exsurge2.GlyphCode.OriscusAsc;else lowerGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      var builder = this.build(ctxt).noteAt(lower, lowerGlyph);
	
	      if (upperStaffPos - lowerStaffPos === 1) // use a virga glyph in this case
	        builder.virgaAt(upper);else if (upper.liquescent === _Exsurge3.LiquescentType.LargeDescending) builder.noteAt(upper, _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent).withLineEndingAt(lower);else builder.noteAt(upper, _Exsurge2.GlyphCode.PunctumQuadratum).withLineEndingAt(lower);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return PesQuassus;
	}(Neume);
	
	/*
	 * PesSubpunctis
	 */
	
	
	var PesSubpunctis = exports.PesSubpunctis = function (_Neume9) {
	  _inherits(PesSubpunctis, _Neume9);
	
	  function PesSubpunctis() {
	    _classCallCheck(this, PesSubpunctis);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(PesSubpunctis).apply(this, arguments));
	  }
	
	  _createClass(PesSubpunctis, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(PesSubpunctis.prototype), 'performLayout', this).call(this, ctxt);
	
	      // podatus followed by inclinati
	      this.build(ctxt).withPodatus(this.notes[0], this.notes[1]).advanceBy(ctxt.intraNeumeSpacing / 2).withInclinati(this.notes.slice(2));
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return PesSubpunctis;
	}(Neume);
	
	/*
	 * Podatus
	 *
	 * This podatus class handles a few neume types actually, depending on the note
	 * data: Podatus (including various liquescent types on the upper note),
	 * Podatus initio debilis, and Quilisma-Pes
	 */
	
	
	var Podatus = exports.Podatus = function (_Neume10) {
	  _inherits(Podatus, _Neume10);
	
	  function Podatus() {
	    _classCallCheck(this, Podatus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Podatus).apply(this, arguments));
	  }
	
	  _createClass(Podatus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	
	      // 1. episema on lower note by default be below, upper note above
	      // 2. morae:
	      //   a. if podatus difference is 1 and lower note is on a line,
	      //      the lower mora should be below
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	      } // if this note has two or more (!?) morae then we just leave them be
	      // since they have already been assigned position hints.
	      if (this.notes[0].morae.length < 2) {
	        for (i = 0; i < this.notes[0].morae.length; i++) {
	          marking = this.notes[0].morae[i];
	
	          if (this.notes[1].staffPosition - this.notes[0].staffPosition === 1 && Math.abs(this.notes[0].staffPosition % 2) === 1) marking.positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	        }
	      }
	
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        if (this.notes[1].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[1].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Podatus.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).withPodatus(this.notes[0], this.notes[1]);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Podatus;
	}(Neume);
	
	/*
	 * Porrectus
	 */
	
	
	var Porrectus = exports.Porrectus = function (_Neume11) {
	  _inherits(Porrectus, _Neume11);
	
	  function Porrectus() {
	    _classCallCheck(this, Porrectus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Porrectus).apply(this, arguments));
	  }
	
	  _createClass(Porrectus, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Porrectus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	
	      var thirdGlyph;
	
	      if (third.liquescent & _Exsurge3.LiquescentType.Small) thirdGlyph = _Exsurge2.GlyphCode.TerminatingAscLiquescent;else if (third.liquescent & _Exsurge3.LiquescentType.Descending) thirdGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else thirdGlyph = _Exsurge2.GlyphCode.PodatusUpper;
	
	      this.build(ctxt).lineFrom(second).withPorrectusSwash(first, second).noteAt(third, thirdGlyph);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Porrectus;
	}(Neume);
	
	/*
	 * PorrectusFlexus
	 */
	
	
	var PorrectusFlexus = exports.PorrectusFlexus = function (_Neume12) {
	  _inherits(PorrectusFlexus, _Neume12);
	
	  function PorrectusFlexus() {
	    _classCallCheck(this, PorrectusFlexus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(PorrectusFlexus).apply(this, arguments));
	  }
	
	  _createClass(PorrectusFlexus, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(PorrectusFlexus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	      var fourth = this.notes[3];
	
	      var thirdGlyph = _Exsurge2.GlyphCode.PunctumQuadratum,
	          fourthGlyph;
	
	      if (fourth.liquescent & _Exsurge3.LiquescentType.Small) {
	        thirdGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	        fourthGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (fourth.liquescent & _Exsurge3.LiquescentType.Ascending) fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (fourth.liquescent & _Exsurge3.LiquescentType.Descending) fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      this.build(ctxt).lineFrom(second).withPorrectusSwash(first, second).noteAt(third, thirdGlyph).noteAt(fourth, fourthGlyph);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return PorrectusFlexus;
	}(Neume);
	
	// this is some type of pseudo nume right? there is no such thing as a neume
	// of puncta inclinata, but this will be part of other composite neumes.
	
	
	var PunctaInclinata = exports.PunctaInclinata = function (_Neume13) {
	  _inherits(PunctaInclinata, _Neume13);
	
	  function PunctaInclinata() {
	    _classCallCheck(this, PunctaInclinata);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(PunctaInclinata).apply(this, arguments));
	  }
	
	  _createClass(PunctaInclinata, [{
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(PunctaInclinata.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).withInclinati(this.notes);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return PunctaInclinata;
	}(Neume);
	
	/*
	 * Punctum
	 */
	
	
	var Punctum = exports.Punctum = function (_Neume14) {
	  _inherits(Punctum, _Neume14);
	
	  function Punctum() {
	    _classCallCheck(this, Punctum);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Punctum).apply(this, arguments));
	  }
	
	  _createClass(Punctum, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	      var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	      // logic here is this: if first episema is default position, place it above.
	      // then place the second one (if there is one) opposite of the first.
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = positionHint;else positionHint = this.notes[0].epismata[i].positionHint;
	
	        // now place the next one in the opposite position
	        positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Punctum.prototype), 'performLayout', this).call(this, ctxt);
	
	      var note = this.notes[0];
	      var glyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      // determine the glyph to use
	      if (note.liquescent !== _Exsurge3.LiquescentType.None) {
	        if (note.shape === _Exsurge3.NoteShape.Inclinatum) glyph = _Exsurge2.GlyphCode.PunctumInclinatumLiquescent;else if (note.shape === _Exsurge3.NoteShape.Oriscus) glyph = _Exsurge2.GlyphCode.OriscusLiquescent;else if (note.liquescent & _Exsurge3.LiquescentType.Ascending) glyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (note.liquescent & _Exsurge3.LiquescentType.Descending) glyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	      } else {
	
	        if (note.shapeModifiers & _Exsurge3.NoteShapeModifiers.Cavum) glyph = _Exsurge2.GlyphCode.PunctumCavum;else if (note.shape === _Exsurge3.NoteShape.Inclinatum) glyph = _Exsurge2.GlyphCode.PunctumInclinatum;else if (note.shape === _Exsurge3.NoteShape.Quilisma) glyph = _Exsurge2.GlyphCode.Quilisma;else glyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	      }
	
	      this.build(ctxt).noteAt(note, glyph);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Punctum;
	}(Neume);
	
	/*
	 * Salicus
	 */
	
	
	var Salicus = exports.Salicus = function (_Neume15) {
	  _inherits(Salicus, _Neume15);
	
	  function Salicus() {
	    _classCallCheck(this, Salicus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Salicus).apply(this, arguments));
	  }
	
	  _createClass(Salicus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i, j;
	
	      // by default place episema below
	      // fixme: is this correct?
	      for (i = 0; i < this.notes.length; i++) {
	        for (j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Salicus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	
	      var builder = this.build(ctxt).noteAt(first, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      // if the next note doesn't require a stem connector, then add a tad bit
	      // of spacing here
	      if (!(second.shapeModifiers & _Exsurge3.NoteShapeModifiers.Stemmed)) builder.advanceBy(ctxt.intraNeumeSpacing);
	
	      // second note is always an oriscus, which may or may not be stemmed
	      // to the first
	      builder.noteAt(second, _Exsurge2.GlyphCode.OriscusAsc);
	
	      // third note can be a punctum quadratum or various liquescent forms
	      if (third.liquescent & _Exsurge3.LiquescentType.Small) builder.noteAt(third, _Exsurge2.GlyphCode.TerminatingAscLiquescent);else if (third.liquescent === _Exsurge3.LiquescentType.Ascending) builder.noteAt(third, _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent);else if (third.liquescent === _Exsurge3.LiquescentType.Descending) builder.noteAt(third, _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent);else builder.virgaAt(third);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Salicus;
	}(Neume);
	
	/*
	 * Salicus Flexus
	 */
	
	
	var SalicusFlexus = exports.SalicusFlexus = function (_Neume16) {
	  _inherits(SalicusFlexus, _Neume16);
	
	  function SalicusFlexus() {
	    _classCallCheck(this, SalicusFlexus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(SalicusFlexus).apply(this, arguments));
	  }
	
	  _createClass(SalicusFlexus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i, j;
	
	      // by default place episema below
	      // fixme: is this correct?
	      for (i = 0; i < this.notes.length; i++) {
	        for (j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(SalicusFlexus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	      var fourth = this.notes[3];
	
	      var builder = this.build(ctxt).noteAt(first, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      // if the next note doesn't require a stem connector, then add a tad bit
	      // of spacing here
	      if (!(second.shapeModifiers & _Exsurge3.NoteShapeModifiers.Stemmed)) builder.advanceBy(ctxt.intraNeumeSpacing);
	
	      // second note is always an oriscus, which may or may not be stemmed
	      // to the first
	      builder.noteAt(second, _Exsurge2.GlyphCode.OriscusAsc);
	
	      // third note can be a punctum quadratum or various liquescent forms,
	      // ...based on note four though!
	      if (fourth.liquescent & _Exsurge3.LiquescentType.Small) builder.noteAt(third, _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent);else builder.noteAt(third, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      // finally, do the fourth note
	      if (fourth.liquescent & _Exsurge3.LiquescentType.Small) builder.noteAt(fourth, _Exsurge2.GlyphCode.TerminatingDesLiquescent);else if (fourth.liquescent & _Exsurge3.LiquescentType.Ascending) builder.noteAt(fourth, _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent);else if (fourth.liquescent & _Exsurge3.LiquescentType.Descending) builder.noteAt(fourth, _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent);else builder.noteAt(fourth, _Exsurge2.GlyphCode.PunctumQuadratum);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return SalicusFlexus;
	}(Neume);
	
	/*
	 * Scandicus
	 */
	
	
	var Scandicus = exports.Scandicus = function (_Neume17) {
	  _inherits(Scandicus, _Neume17);
	
	  function Scandicus() {
	    _classCallCheck(this, Scandicus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Scandicus).apply(this, arguments));
	  }
	
	  _createClass(Scandicus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	
	      // by default place first note epismata below
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	      }var positionHint = this.notes[2].shape === _Exsurge3.NoteShape.Virga ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        if (this.notes[1].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[1].epismata[i].positionHint = positionHint;
	      } // by default place third note epismata above
	      for (i = 0; i < this.notes[2].epismata.length; i++) {
	        if (this.notes[2].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[2].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	
	    // if the third note shape is a virga, then the scadicus is rendered
	    // as a podatus followed by a virga. Otherwise, it's rendered as a
	    // punctum followed by a podatus...
	
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Scandicus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	
	      if (third.shape === _Exsurge3.NoteShape.Virga) {
	        this.build(ctxt).withPodatus(first, second).virgaAt(third);
	      } else {
	        this.build(ctxt).noteAt(first, _Exsurge2.GlyphCode.PunctumQuadratum).withPodatus(second, third);
	      }
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Scandicus;
	}(Neume);
	
	/*
	 * Scandicus Flexus
	 */
	
	
	var ScandicusFlexus = exports.ScandicusFlexus = function (_Neume18) {
	  _inherits(ScandicusFlexus, _Neume18);
	
	  function ScandicusFlexus() {
	    _classCallCheck(this, ScandicusFlexus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(ScandicusFlexus).apply(this, arguments));
	  }
	
	  _createClass(ScandicusFlexus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	
	      // by default place first note epismata below
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Below;
	      }var positionHint = this.notes[2].shape === _Exsurge3.NoteShape.Virga ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        if (this.notes[1].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[1].epismata[i].positionHint = positionHint;
	      } // by default place third note epismata above
	      for (i = 0; i < this.notes[2].epismata.length; i++) {
	        if (this.notes[2].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[2].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      } // by default place fourth note epismata above
	      for (i = 0; i < this.notes[3].epismata.length; i++) {
	        if (this.notes[3].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[3].epismata[i].positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(ScandicusFlexus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	      var fourth = this.notes[3];
	
	      if (third.shape === _Exsurge3.NoteShape.Virga) {
	        this.build(ctxt).withPodatus(first, second).advanceBy(ctxt.intraNeumeSpacing).withClivis(third, fourth);
	      } else {
	        var fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	        if (fourth.liquescent & _Exsurge3.LiquescentType.Ascending) fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (fourth.liquescent & _Exsurge3.LiquescentType.Descending) fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	
	        this.build(ctxt).noteAt(first, _Exsurge2.GlyphCode.PunctumQuadratum).withPodatus(second, third).advanceBy(ctxt.intraNeumeSpacing).noteAt(fourth, fourthGlyph);
	      }
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return ScandicusFlexus;
	}(Neume);
	
	/*
	 * Torculus
	 */
	
	
	var Torculus = exports.Torculus = function (_Neume19) {
	  _inherits(Torculus, _Neume19);
	
	  function Torculus() {
	    _classCallCheck(this, Torculus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Torculus).apply(this, arguments));
	  }
	
	  _createClass(Torculus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	      var hasMiddleEpisema = false;
	
	      // first do the middle note to see if we should try to move
	      // epismata on the other two lower notes
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        marking = this.notes[1].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) {
	          marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	          hasMiddleEpisema = true;
	        }
	      }
	
	      // 1. episema on lower notes should be below, upper note above
	      // 2. morae: fixme: implement
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        marking = this.notes[0].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[2].epismata.length; i++) {
	        marking = this.notes[2].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Torculus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var note1 = this.notes[0];
	      var note2 = this.notes[1];
	      var note3 = this.notes[2];
	
	      var glyph1, glyph3;
	
	      if (note1.liquescent === _Exsurge3.LiquescentType.InitioDebilis) glyph1 = _Exsurge2.GlyphCode.TerminatingDesLiquescent;else if (note1.shape === _Exsurge3.NoteShape.Quilisma) glyph1 = _Exsurge2.GlyphCode.Quilisma;else glyph1 = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      if (note3.liquescent & _Exsurge3.LiquescentType.Small) glyph3 = _Exsurge2.GlyphCode.TerminatingDesLiquescent;else if (note3.liquescent & _Exsurge3.LiquescentType.Ascending) glyph3 = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (note3.liquescent & _Exsurge3.LiquescentType.Descending) glyph3 = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else glyph3 = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      this.build(ctxt).noteAt(note1, glyph1).noteAt(note2, _Exsurge2.GlyphCode.PunctumQuadratum).noteAt(note3, glyph3);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Torculus;
	}(Neume);
	
	/*
	 * TorculusResupinus
	 */
	
	
	var TorculusResupinus = exports.TorculusResupinus = function (_Neume20) {
	  _inherits(TorculusResupinus, _Neume20);
	
	  function TorculusResupinus() {
	    _classCallCheck(this, TorculusResupinus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(TorculusResupinus).apply(this, arguments));
	  }
	
	  _createClass(TorculusResupinus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	      var hasMiddleEpisema = false;
	
	      // first do the middle note to see if we should try to move
	      // epismata on the other two lower notes
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        marking = this.notes[1].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) {
	          marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	          hasMiddleEpisema = true;
	        }
	      }
	
	      // 1. episema on lower notes should be below, upper note above
	      // 2. morae: fixme: implement
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        marking = this.notes[0].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[2].epismata.length; i++) {
	        marking = this.notes[2].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[3].epismata.length; i++) {
	        marking = this.notes[3].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(TorculusResupinus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	      var fourth = this.notes[3];
	
	      var firstGlyph, fourthGlyph;
	
	      if (first.liquescent === _Exsurge3.LiquescentType.InitioDebilis) {
	        firstGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (first.shape === _Exsurge3.NoteShape.Quilisma) firstGlyph = _Exsurge2.GlyphCode.Quilisma;else firstGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      if (fourth.liquescent & _Exsurge3.LiquescentType.Small) fourthGlyph = _Exsurge2.GlyphCode.TerminatingAscLiquescent;else if (third.liquescent & _Exsurge3.LiquescentType.Descending) fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else fourthGlyph = _Exsurge2.GlyphCode.PodatusUpper;
	
	      this.build(ctxt).noteAt(first, firstGlyph).withPorrectusSwash(second, third).noteAt(fourth, fourthGlyph);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return TorculusResupinus;
	}(Neume);
	
	/*
	 * TorculusResupinusFlexus
	 */
	
	
	var TorculusResupinusFlexus = exports.TorculusResupinusFlexus = function (_Neume21) {
	  _inherits(TorculusResupinusFlexus, _Neume21);
	
	  function TorculusResupinusFlexus() {
	    _classCallCheck(this, TorculusResupinusFlexus);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(TorculusResupinusFlexus).apply(this, arguments));
	  }
	
	  _createClass(TorculusResupinusFlexus, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i;
	      var hasMiddleEpisema = false;
	
	      // first do the middle note to see if we should try to move
	      // epismata on the other two lower notes
	      for (i = 0; i < this.notes[1].epismata.length; i++) {
	        marking = this.notes[1].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) {
	          marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	          hasMiddleEpisema = true;
	        }
	      }
	
	      // 1. episema on lower notes should be below, upper note above
	      // 2. morae: fixme: implement
	      for (i = 0; i < this.notes[0].epismata.length; i++) {
	        marking = this.notes[0].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[2].epismata.length; i++) {
	        marking = this.notes[2].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = hasMiddleEpisema ? _ExsurgeChant.MarkingPositionHint.Above : _ExsurgeChant.MarkingPositionHint.Below;
	      }
	
	      for (i = 0; i < this.notes[3].epismata.length; i++) {
	        marking = this.notes[3].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	
	      for (i = 0; i < this.notes[4].epismata.length; i++) {
	        marking = this.notes[4].epismata[i];
	
	        if (marking.positionHint === _ExsurgeChant.MarkingPositionHint.Default) marking.positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(TorculusResupinusFlexus.prototype), 'performLayout', this).call(this, ctxt);
	
	      var first = this.notes[0];
	      var second = this.notes[1];
	      var third = this.notes[2];
	      var fourth = this.notes[3];
	      var fifth = this.notes[4];
	
	      var firstGlyph,
	          fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratum,
	          fifthGlyph;
	
	      if (first.liquescent === _Exsurge3.LiquescentType.InitioDebilis) {
	        firstGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (first.shape === _Exsurge3.NoteShape.Quilisma) firstGlyph = _Exsurge2.GlyphCode.Quilisma;else firstGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      if (fifth.liquescent & _Exsurge3.LiquescentType.Small) {
	        fourthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;
	        fifthGlyph = _Exsurge2.GlyphCode.TerminatingDesLiquescent;
	      } else if (fifth.liquescent & _Exsurge3.LiquescentType.Ascending) fifthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumAscLiquescent;else if (fifth.liquescent & _Exsurge3.LiquescentType.Descending) fifthGlyph = _Exsurge2.GlyphCode.PunctumQuadratumDesLiquescent;else fifthGlyph = _Exsurge2.GlyphCode.PunctumQuadratum;
	
	      this.build(ctxt).noteAt(first, firstGlyph).withPorrectusSwash(second, third).noteAt(fourth, fourthGlyph).noteAt(fifth, fifthGlyph);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return TorculusResupinusFlexus;
	}(Neume);
	
	/*
	 * Tristropha
	 *
	 * For simplicity in implementation, Tristropha's have three notes in the object
	 * structure. These technically must be the same pitch though (like the
	 * Distropha and Bivirga).
	 */
	
	
	var Tristropha = exports.Tristropha = function (_Neume22) {
	  _inherits(Tristropha, _Neume22);
	
	  function Tristropha() {
	    _classCallCheck(this, Tristropha);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Tristropha).apply(this, arguments));
	  }
	
	  _createClass(Tristropha, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var marking, i, j;
	
	      for (i = 0; i < this.notes.length; i++) {
	        var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	        // logic here is this: if first episema is default position, place it above.
	        // then place the second one (if there is one) opposite of the first.
	        for (j = 0; j < this.notes[i].epismata.length; j++) {
	          if (this.notes[i].epismata[j].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[i].epismata[j].positionHint = positionHint;else positionHint = this.notes[i].epismata[j].positionHint;
	
	          // now place the next one in the opposite position
	          positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	        }
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Tristropha.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).noteAt(this.notes[0], Apostropha.getNoteGlyphCode(this.notes[0])).advanceBy(ctxt.intraNeumeSpacing).noteAt(this.notes[1], Apostropha.getNoteGlyphCode(this.notes[1])).advanceBy(ctxt.intraNeumeSpacing).noteAt(this.notes[2], Apostropha.getNoteGlyphCode(this.notes[2]));
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Tristropha;
	}(Neume);
	
	/*
	 * Virga
	 */
	
	
	var Virga = exports.Virga = function (_Neume23) {
	  _inherits(Virga, _Neume23);
	
	  function Virga() {
	    _classCallCheck(this, Virga);
	
	    return _possibleConstructorReturn(this, Object.getPrototypeOf(Virga).apply(this, arguments));
	  }
	
	  _createClass(Virga, [{
	    key: 'positionMarkings',
	    value: function positionMarkings() {
	      var positionHint = _ExsurgeChant.MarkingPositionHint.Above;
	
	      // logic here is this: if first episema is default position, place it above.
	      // then place the second one (if there is one) opposite of the first.
	      for (var i = 0; i < this.notes[0].epismata.length; i++) {
	        if (this.notes[0].epismata[i].positionHint === _ExsurgeChant.MarkingPositionHint.Default) this.notes[0].epismata[i].positionHint = positionHint;else positionHint = this.notes[0].epismata[i].positionHint;
	
	        // now place the next one in the opposite position
	        positionHint = positionHint === _ExsurgeChant.MarkingPositionHint.Above ? _ExsurgeChant.MarkingPositionHint.Below : _ExsurgeChant.MarkingPositionHint.Above;
	      }
	    }
	  }, {
	    key: 'performLayout',
	    value: function performLayout(ctxt) {
	      _get(Object.getPrototypeOf(Virga.prototype), 'performLayout', this).call(this, ctxt);
	
	      this.build(ctxt).virgaAt(this.notes[0]);
	
	      this.finishLayout(ctxt);
	    }
	  }]);
	
	  return Virga;
	}(Neume);

/***/ }
/******/ ])
});
;
//# sourceMappingURL=exsurge.js.map
