
<%@page import="java.sql.ResultSet"%>
<%@page import="java.awt.print.Paper"%>
<%@page import="dr.DBManager"%>
<%@page import="org.apache.wiki.workflow.Decision"%>
<%@page import="org.apache.wiki.workflow.Workflow"%>
<%@page import="org.apache.wiki.workflow.Fact"%>
<%@page import="org.apache.wiki.auth.UserManager.SaveUserProfileTask"%>
<%@page import="org.apache.wiki.workflow.Task"%>
<%@page import="org.apache.wiki.workflow.WorkflowBuilder"%>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="java.security.Principal" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.login.CookieAssertionLoginModule" %>
<%@ page import="org.apache.wiki.auth.login.CookieAuthenticationLoginModule" %>
<%@ page import="org.apache.wiki.auth.user.DuplicateUserException" %>
<%@ page import="org.apache.wiki.auth.user.UserProfile" %>
<%@ page import="org.apache.wiki.i18n.InternationalizationManager" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.wiki.tags.WikiTagBase" %>
<%@ page import="org.apache.wiki.workflow.DecisionRequiredException" %>
<%@ page errorPage="/Error.jsp" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<%!
    Logger log = Logger.getLogger("JSPWiki");
%>
<%
  	String op = request.getParameter("op");
  	String msg="";
  	if(op != null)
  	{
  		if(op.equals("add"))
  		{
  			String title = request.getParameter("title");
  			String authors = request.getParameter("authors");
  			String keywords = request.getParameter("keywords");
  			String info = request.getParameter("info");
  			String pp_abstract = request.getParameter("abstract");
  			String custom_info = request.getParameter("custom_info");
  		   DBManager db=new DBManager("insert into papers values(?,?,?,?,?,?,?)");
  		   String id;
			UUID uuid=UUID.randomUUID();
          	id=uuid.toString().toLowerCase();
          	id="4"+id;
  		   db.pst.setString(1, id);
  		   db.pst.setString(2, title);
  		   db.pst.setString(3, authors);
  		   db.pst.setString(4, keywords);
  		   db.pst.setString(5, info);
  		   db.pst.setString(6, pp_abstract);
  		   db.pst.setString(7, custom_info);
	       int rs=db.pst.executeUpdate();
	       if(rs > 0)
	       {
	     		msg = "添加成功！";
	       }
	       else
	       {
	       		msg = "添加失败！";
	       }
	       db.close();
  		}
  		else
  		{
  			String id = request.getParameter("id");
  		   DBManager db=new DBManager("delete from papers where id=?");
  		   db.pst.setString(1, id);
	       int rs=db.pst.executeUpdate();
	       if(rs > 0)
	       {
	     		msg = "删除成功！";
	       }
	       else
	       {
	       		msg = "删除失败！";
	       }
	       db.close();
  			
  		}
  	}
  	//中文需要编码
	msg=java.net.URLEncoder.encode(msg.toString(),"utf-8");
    response.sendRedirect("Home.jsp?tag=papers&msg="+msg);

%>