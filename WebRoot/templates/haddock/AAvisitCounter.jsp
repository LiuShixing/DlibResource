<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" pageEncoding="UTF-8"%>  
 <%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<div class="visit_counter pull-right">
 <%
 	int count = DBManager.getCount();
     if(session.isNew())
       {System.out.println("AAvisitCounter.jsp: new session");
            count = DBManager.incTodayCounter();
       }
       Date date = new Date();
       SimpleDateFormat sdf = new SimpleDateFormat("yyyy");
      %>
      <br/>
      <%=sdf.format(date) %>年访问量: <%=count %>
</div>