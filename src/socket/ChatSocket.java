package socket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.swing.text.AbstractDocument.Content;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;

import vo.ContentVo;
import vo.Message;

@ServerEndpoint("/chatSocket")
public class ChatSocket {

	private String username;
	private static List<Session> sessions = new ArrayList<Session>();
	private static Map<String, Session> map = new HashMap<String, Session>();
	private static List<String> names = new ArrayList<String>();

	@OnOpen
	public void open(Session session) {
		String queryString = session.getQueryString();
		System.out.println(queryString);
		username = queryString.split("=")[1];
		System.out.println(username);
		this.names.add(username);
		this.sessions.add(session);
		this.map.put(this.username, session);

		String msg = "<font color=red>欢迎" + this.username
				+ "进入聊天室！<br/></font>";

		Message message = new Message();
		message.setWelcome(msg);
		message.setUsername(this.names);

		this.broadcast(this.sessions, message.toJson());
	}

	private void broadcast(List<Session> ss, String msg) {
		for (Iterator iterator = ss.iterator(); iterator.hasNext();) {
			try {
				Session session = (Session) iterator.next();
				session.getBasicRemote().sendText(msg);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	}

	@OnClose
	public void close(Session session) {

		this.sessions.remove(session);
		this.names.remove(username);

		String msg = "<font color=red>欢送" + this.username
				+ "离开聊天室！<br/></font>";
		Message message = new Message();
		message.setWelcome(msg);
		message.setUsername(this.names);

		broadcast(this.sessions, message.toJson());
	}

	private static Gson gson = new Gson();

	@OnMessage
	public void message(Session session, String json) {

		ContentVo vo = gson.fromJson(json, ContentVo.class);
		if (vo.getType() == 1) {
			Message message = new Message();
			message.setContent(username, vo.getMsg());
			broadcast(sessions, message.toJson());
		} else {
			String to = vo.getTo();
			Session to_session = this.map.get(to);
			Message message = new Message();
			message.setContent("<font color=blue>" + this.username + "</font>",
					"<font color=blue>单聊:" + vo.getMsg() + "</font>");
			try {
				to_session.getBasicRemote().sendText(message.toJson());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

	}
}
