/*jslint node: true, indent: 4, stupid: true, nomen: true */
"use strict";

var getFromUserAcount,
    putToHomelessAcount,
    transferServiceClass = require('../mastercard-api-node-master/services/moneysend/TransferService'),
    environment = require('../mastercard-api-node-master/common/Environment'),
    cardMappingServiceClass = require('../mastercard-api-node-master/services/moneysend/CardMappingService'),
    transferService,
    cardMapService,
    generatePrivateKeyForTest,
    fs = require("fs"),
    request = require("request"),
    testKey = "tiFlYdwac171585cDrJtc-ghJ--7ufECpU5FFSYeab056910!415055685265724259576c72693643574571417a6451733d",
    keyPath,
    pathLib = require('path'),
    createCardMapping,
    enquireCardMapping,
    data = require("./data.json"),
    putAmountToDb,
    substractAmountToDb,
    JsonDB = require('node-json-db'),
    db = new JsonDB("myDataBase", true, true),
    createUser,
    createUserCardMapping,
    getUserDetails;

keyPath = pathLib.dirname(process.mainModule.filename) + "/keys/mastercard.homelesshelp.com.key";

generatePrivateKeyForTest = function(env){
    var pem;
    if (env == environment.production) {
        pem = fs.readFileSync(keyPath);
    } else {
        pem = fs.readFileSync(keyPath);
    }
    return pem.toString('utf8')
};

putAmountToDb = function (toWhom, amount, fromSubscriberId, fromSubscriberAlias) {
    var moenyReceived;
    moenyReceived = db.getData("/homelessppl/" + toWhom + "/moneyRecievedFrom");
    moenyReceived.push({
        "SubscriberId": fromSubscriberId,
        "SubscriberAlias": fromSubscriberAlias,
        "amount": parseInt(amount, 10)
    });
    db.push("/homelessppl/" + toWhom + "/totalMoney", parseInt(db.getData("/homelessppl/" + toWhom + "/totalMoney"), 10) + parseInt(amount, 10));
    db.push("/homelessppl/" + toWhom + "/moneyRecievedFrom", moenyReceived);
};

substractAmountToDb = function (amount, merchant, toSubscriberId) {
    var merchantValues;
    merchantValues = db.getData("/homelessppl/" + toSubscriberId + "/merchant");
    merchantValues.push(merchant);
    db.push("/homelessppl/" + toSubscriberId + "/merchant", merchantValues);
    db.push("/homelessppl/" + toSubscriberId + "/totalMoney", parseInt(db.getData("/homelessppl/" + toSubscriberId + "/totalMoney"), 10) - parseInt(amount, 10));
};

getFromUserAcount = function (req, res) {
    var requestObj, toWhom, amount,fromSubscriberId, fromSubscriberAlias;

    amount = req.body.amount;
    fromSubscriberId = req.body.fromSubscriberId;
    fromSubscriberAlias = req.body.fromSubscriberAlias;
    toWhom = req.body.toSubscriberId;

    requestObj = data.moneysend.receiveFrom;
    requestObj.FundingRequest.TransactionReference.push("144652" + new Date().getTime());
    requestObj.FundingRequest.FundingMapped[0].SubscriberId.push(fromSubscriberId);
    requestObj.FundingRequest.FundingMapped[0].SubscriberAlias.push(fromSubscriberAlias);
    requestObj.FundingRequest.FundingAmount[0].Value.push(amount);


    console.log("########################################");
    console.log("");
    console.log("requestObj " + JSON.stringify(requestObj));
    console.log("");
    console.log("########################################");
    console.log("");

    function transferServiceCallBack (result) {
        console.log("");
        console.log("########################################");
        console.log("");
        console.log("result " + JSON.stringify(result));
        console.log("");
        console.log("########################################");
        console.log("");
        if (result.Transfer && result.Transfer.TransactionHistory && result.Transfer.TransactionHistory[0].Transaction[0]
                && result.Transfer.TransactionHistory[0].Transaction[0].Response[0] && result.Transfer.TransactionHistory[0].Transaction[0].Response[0].Code[0]
                    && result.Transfer.TransactionHistory[0].Transaction[0].Response[0].Code[0] === "00") {
            putAmountToDb(toWhom, amount, fromSubscriberId, fromSubscriberAlias);
            res.send(JSON.stringify({"meta": {"status": "success"}, "data": result}));
        } else {
            res.send({"meta": {"status": "failure"}});
        }

    }

    transferService = new transferServiceClass.TransferService(testKey, generatePrivateKeyForTest(environment.sandbox), environment.sandbox, transferServiceCallBack);
    transferService.getTransfer(requestObj);
};

putToHomelessAcount = function (req, res) {
    var requestObj, toWhom,toSubscriberId, toSubscriberAlias, amount, merchant;

    toSubscriberId = req.body.toSubscriberId;
    toSubscriberAlias = req.body.toSubscriberAlias;
    merchant = req.body.merchant || "";
    amount = req.body.amount || db.getData("/homelessppl/" + toSubscriberId + "/totalMoney");

    requestObj = data.moneysend.senderTo;
    requestObj.FundingRequest.TransactionReference.push("144652" + new Date().getTime());
    requestObj.FundingRequest.ReceivingMapped[0].SubscriberId.push(toSubscriberId);
    requestObj.FundingRequest.ReceivingMapped[0].SubscriberAlias.push(toSubscriberAlias);
    requestObj.FundingRequest.FundingAmount[0].Value.push(amount);


    console.log("########################################");
    console.log("");
    console.log("requestObj " + JSON.stringify(requestObj));
    console.log("");
    console.log("########################################");
    console.log("");

    function transferServiceCallBack (result) {
        console.log("");
        console.log("########################################");
        console.log("");
        console.log("result " + JSON.stringify(result));
        console.log("");
        console.log("########################################");
        console.log("");
        if (result.Transfer && result.Transfer.TransactionHistory && result.Transfer.TransactionHistory[0].Transaction[0]
            && result.Transfer.TransactionHistory[0].Transaction[0].Response[0] && result.Transfer.TransactionHistory[0].Transaction[0].Response[0].Code[0]
            && result.Transfer.TransactionHistory[0].Transaction[0].Response[0].Code[0] === "00") {
            substractAmountToDb(amount, merchant, toSubscriberId);
            res.send(JSON.stringify({"meta": {"status": "success"}, "data": result}));
        } else {
            res.send({"meta": {"status": "failure"}});
        }

    }

    transferService = new transferServiceClass.TransferService(testKey, generatePrivateKeyForTest(environment.sandbox), environment.sandbox, transferServiceCallBack);
    transferService.getTransfer(requestObj);
};

createCardMapping = function (req, res) {
    var requestObj;

    if (req.query.type === "org") {
        requestObj = data.createMapping.org;
    } else if (req.query.type === "sender") {
        requestObj = data.createMapping.sender;
    } else {
        requestObj = data.createMapping.reciever;
    }

    function cardMapServiceCallBack (result) {
        res.send(JSON.stringify(result));
    }

    cardMapService = new cardMappingServiceClass.CardMappingService(testKey, generatePrivateKeyForTest(environment.sandbox), environment.sandbox, cardMapServiceCallBack);
    cardMapService.getCreateMapping(requestObj);

};

enquireCardMapping = function (req, res) {
    var requestObj;

    if (req.query.type === "org") {
        requestObj = data.enquire.org;
    } else if (req.query.type === "sender") {
        requestObj = data.enquire.sender;
    } else {
        requestObj = data.enquire.reciever;
    }

    function cardMapServiceCallBack (result) {
        console.log("");
        console.log("########################################");
        console.log("");
        console.log("result " + JSON.stringify(result));
        console.log("");
        console.log("########################################");
        console.log("");
        res.send(JSON.stringify(result));
    }

    cardMapService = new cardMappingServiceClass.CardMappingService(testKey, generatePrivateKeyForTest(environment.sandbox), environment.sandbox, cardMapServiceCallBack);
    cardMapService.getInquireMapping(requestObj);

};

createUserCardMapping = function (SubscriberId, SubscriberAlias, cb) {
    var requestObj;

    requestObj = data.createMapping.reciever;
    requestObj.CreateMappingRequest.SubscriberId = SubscriberId;
    requestObj.CreateMappingRequest.Alias = SubscriberAlias;

    function cardMapServiceCallBack (result) {
        cb(JSON.stringify(result));
    }

    cardMapService = new cardMappingServiceClass.CardMappingService(testKey, generatePrivateKeyForTest(environment.sandbox), environment.sandbox, cardMapServiceCallBack);
    cardMapService.getCreateMapping(requestObj);
};

createUser = function (req, res) {
    var SubscriberId, SubscriberAlias, tempUserObj, otherUserDetails;

    SubscriberId = req.body.userId;
    SubscriberAlias = req.body.userAlias;
    otherUserDetails = req.body.otherUserDetails;

    createUserCardMapping(SubscriberId, SubscriberAlias, function (result) {
        tempUserObj = {
            "SubscriberId": SubscriberId,
            "SubscriberAlias": SubscriberAlias,
            "totalMoney": 0,
            "otherUserDetails": otherUserDetails,
            "moneyRecievedFrom":[],
            "merchant":[]
        };
        db.push("/homelessppl/" + SubscriberId, tempUserObj);
        res.send(JSON.stringify({"meta": {"status": "success"}, "data": result}));
    });
};

getUserDetails = function (req, res) {
    var SubscriberId, tempObj;

    SubscriberId = req.body.userId;
    tempObj = db.getData("/homelessppl/" + SubscriberId);
    res.send(JSON.stringify({"meta": {"status": "success"}, "data": tempObj}));
};

module.exports = {
    getFromUserAcount: getFromUserAcount,
    putToHomelessAcount: putToHomelessAcount,
    createCardMapping: createCardMapping,
    enquireCardMapping: enquireCardMapping,
    createUser: createUser,
    getUserDetails: getUserDetails
};