<%@page import="java.text.DateFormat"%>
<%@page import="servlet.Article"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.ui.progress.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="java.security.Permission" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>

<%
	String fullName=request.getParameter("fullName");
	String sql="select * from homepage where fullname=?";
	DBManager db=new DBManager(sql);
	db.pst.setString(1,fullName);
	ResultSet rs=db.pst.executeQuery();
	if(rs.next())
	{
		String pageid=rs.getString("pageid");
		rs.close();
		db.close();
		//中文需要编码
		fullName=java.net.URLEncoder.encode(fullName.toString(),"utf-8");   
		response.sendRedirect("Wiki.jsp?page="+pageid+"&tag=user&fullName="+fullName);
	}
	else
	{
		rs.close();
		db.close();
		
		String id;
		UUID uuid=UUID.randomUUID();
		id=uuid.toString().toLowerCase();
		id="3"+id;
		
		//中文需要编码
		fullName=java.net.URLEncoder.encode(fullName.toString(),"utf-8");   
		response.sendRedirect("AddUserPage.jsp?fullName="+fullName+"&page="+id);
	}
	
%>
