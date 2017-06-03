<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<%=basePath%>">

<title>欢迎进入缘分天空聊天页面</title>

<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
<meta http-equiv="description" content="This is my page">
<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->

</head>

<body>
	<div id="container"
		style="border:1px solid black;width:400px;height:400px;float:left;">
		<div id="content" style="height:350px;overflow:auto;"></div>
		<div style="border-top:1px solid black;width:400px;height:50px;">
			<input id="msg" style="width:200px;height:25px;">
			<button style="width:60px;height:25px;" onclick="subSend();" title="">
				<font style="font-weight:bold;font-size:10px;">发送</font>
			</button>
		</div>
	</div>
	<div id="userList"
		style="border:1px solid black;width:100px;height:400px;float:left;">
	</div>


	<script type="text/javascript" src="jquery-1.4.4.min.js"></script>
	<script type="text/javascript">
		var username = "${sessionScope.username }";
		var ws;
		var target = "ws://localhost:8080/chatwebsocket/chatSocket?username="
				+ username;
		window.onload = function() {

			if ("WebSocket" in window) {
				ws = new WebSocket(target);
			} else if ("MozWebSocket" in window) {
				ws = new MozWebSocket(target);
			} else {
				alert("WebSocket不支持浏览器");
				return;
			}

			ws.onmessage = function(event) {

				eval("var msg=" + event.data + ";");
				if (undefined != msg.welcome) {
					$("#content").append(msg.welcome);
				}

				if (undefined != msg.usernames) {
					$("#userList").html("");
					$(msg.usernames).each(
							function() {

								$("#userList").append(
										"<input type=checkbox value='"+this+"'>"
												+ this + "<br/>")

							});
				}

				if (undefined != content) {
					$("#content").append(msg.content);
				}
			}
		}

		function subSend() {
			var ss = $("#userList :checked");
			var val = $("#msg").val();
			console.info(ss.size());
			var obj = null;
			if (ss.size() == 0) {
				obj = {
					msg : val,
					type : 1
				}
				$("#msg").val("");
			} else {
				var to = $("#userList :checked").val();
				obj = {
					to : to,
					msg : val,
					type : 2
				}

			}
			var str = JSON.stringify(obj);
			ws.send(str);
			console.info(str);
		}
	</script>
</body>
</html>
