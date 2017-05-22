var app = require('express')();
var http = require('http').Server(app);
var io   = require('socket.io')(http);



app.get('/',function(req,res){
    res.sendfile(__dirname + '/index.html');
});
http.listen(3000,function () {
    console.log('listien 3000');
});

var socketArray = new Array();

io.on('connection', function(socket){
    var islogin = false;
    console.log('**********新加入了一个用户*********',socket.id);
    socket.on('login',function (userId) {
       if(islogin) return;
        socket.userId = userId;
        socketArray.push(socket);
       islogin = true;

    });
    socket.on('privateMessage',function (data) {
        console.log(data);
    })
    socket.on('chat message', function(data){
        var to   = data.toUser;
        var message = data.message;
        for(var i = 0;i<socketArray.length;i++){
            var receiveData = socketArray[i];
            if (receiveData.userId == to){
                console.log('*******socket Id =',receiveData.socketId);
                io.to([receiveData.id]).emit('privateMessage',''+receiveData.userId+'：'+message);
            }
        }
    });
    socket.on('disconnect',function () {
        console.log('***********用户退出登陆************,'+socket.id);
    })
});


