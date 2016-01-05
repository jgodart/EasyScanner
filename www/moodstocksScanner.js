/*
  moodstocksScanner.js
  Created by Godart Jeoffrey on 05/01/201§.
*/

var  moodstocksScanner{

	openScanner: function (successCallback, errorCallback,api_key,api_secret,bundleName) {
		cordova.exec(successCallback, errorCallback, 'easyScannerPlugin', 'openScanner', [{
			"api_key": api_key,"api_secret": api_secret, "bundleName": bundleName
        }]);
	}
	closeScanner:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'easyScannerPlugin','closeScanner',[]);
	}

	synchro:function(successCallback,errorCallback){
		cordova.exec(successCallback, errorCallback, 'easyScannerPlugin', 'synchroScanner',[]);
	}

	autoScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'easyScannerPlugin','autoScan',[]);
	}

	tapToScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'easyScannerPlugin','tapToScan'),[]);
	}
	pauseScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'easyScannerPlugin','pauseScan'),[]);
	}
	resumeScan:function(successCallback,errorCallback){
		cordova.exec(successCallback,errorCallback,'easyScannerPlugin','resumeScan'),[]);
	}
}
module.exports = moodstocksScanner;