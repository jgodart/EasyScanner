/*
  moodstocksScanner.js
  Created by Godart Jeoffrey on 05/01/201§.
*/

var  moodstocksScanner = {

	openScanner: function (successCallback, errorCallback,api_key,api_secret,bundleName) {
		if (typeof bundleName == null) {
			cordova.exec(successCallback, errorCallback, 'moodstocksScanner', 'openScanner', [{
				"api_key": api_key , "api_secret": api_secret
				}]);
		} else {
			
			cordova.exec(successCallback, errorCallback, 'moodstocksScanner', 'openScanner', [{
				"bundleName": bundleName ,"api_key": api_key , "api_secret": api_secret 
        	}]);
		}
	},
	closeScanner:function(successCallback,errorCallback){
	  cordova.exec(successCallback,errorCallback,'moodstocksScanner','closeScanner',[]);
	},

	synchro:function(successCallback,errorCallback){
	  cordova.exec(successCallback, errorCallback, 'moodstocksScanner', 'synchroScanner',[]);
	},

	Scan:function(successCallback,errorCallback,scanOptions, scanFlags){
		// grab parameters from the scanOptions object
		// Scan formats
		var scanFormats = {
			ean8: 1 << 0,
			/* EAN8 linear barcode */
			ean13: 1 << 1,
			/* EAN13 linear barcode */
			qrcode: 1 << 2,
			/* QR Code 2D barcode */
			dmtx: 1 << 3,
			/* Datamatrix 2D barcode */
			image: 1 << 31 /* Image match */
		}

		var formats = 0;
		// Compile the selected scanning formats into a single Hex code the Moodstocks Native Plugin understands
		for (strFormat in scanFormats) {
			if (scanOptions[strFormat]) {
				formats |= scanFormats[strFormat]; // this it the Bitwise OR Assignment Operator 
			}
		}

		// grab parameters from the scanFlags object. Use defaults if not provided
		if (typeof (scanFlags['useDeviceOrientation']) !== null) {
			deviceOrientation = scanFlags['useDeviceOrientation']
		} else {
			deviceOrientation = false;
		}
		if (typeof (scanFlags['noPartialMatching']) !== null) {
			noPartial = scanFlags['noPartialMatching'];
		} else {
			noPartial = false;
		}
		if (typeof (scanFlags['smallTargetSupport']) !== null) {
			smallTarget = scanFlags['smallTargetSupport'];

		} else {
			smallTarget = false;
		}
		if (typeof (scanFlags['returnQueryFrame']) !== null) {
			returnQueryFrame = scanFlags['queryFrame'];
		} else {
			returnQueryFrame = false;
		}

		cordova.exec(successCallback, errorCallback, 'MS4Plugin', 'scan', [{
			"scanType": scanOptions['scanType'],
			"scanFormats": formats,
			"useDeviceOrientation": deviceOrientation,
			"noPartialMatching": noPartial,
			"smallTargetSupport": smallTarget,
			"returnQueryFrame": returnQueryFrame,
        }]);
	},
	dismiss: function (successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, 'moodstocksScanner', 'stopScan', []);
	},
	tapToScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'moodstocksScanner','tapToScan',[]);
	},
	pauseScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'moodstocksScanner','pauseScan',[]);
	},
	resumeScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'moodstocksScanner','resumeScan',[]);
	}
}
module.exports = moodstocksScanner;