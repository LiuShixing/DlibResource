<%--
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
--%>

<%@page import="javax.sound.midi.MidiDevice.Info"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map"%>
<%@page import="servlet.ResourceInfo"%>
<%@page import="servlet.MyUtil"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.attachment.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>


<%!
   String getPrintSize(long size)
   {
	     if(size<1024)
	     {
	        return String.valueOf(size)+"B";
	     }else {
	         size=size/1024;
	     }
	     
	     if(size<1024){
	        return String.valueOf(size)+"KB";
	     }else{
	       size=size/1024;
	     }
	     
	     if(size<1024){
	        size=size*100;
	        return String.valueOf((size/100))+"."+String.valueOf((size%100))+"MB";
	     }else{
	        size=size*100/1024;
	        return String.valueOf((size/100))+"."+String.valueOf((size%100))+"GB";
	     }
     
     }

 %>
 
<%
  WikiContext c = WikiContext.findContext( pageContext );
  WikiEngine wikiEngine = WikiEngine.getInstance( getServletConfig() );
%>

	
	<% 	
           HttpSession sess = request.getSession();
           
           String ID = (String)sess.getAttribute(MyUtil.REQ_RES_ID);
           String q = request.getParameter("query");
           String redirect = request.getParameter("redirect");
           if(ID!=null && q==null && redirect==null )  //避免在某些情况下显示
           {
               ServletContext app = request.getServletContext();
               Map<String,ResourceInfo> mp=(Map<String,ResourceInfo>)app.getAttribute(MyUtil.RESOURCE_INFO_MP);
        
		       ResourceInfo info = mp.get(ID.toLowerCase());
		       
		       if(info!=null && wikiEngine.pageExists(info.getID()))
		       {
				   SimpleDateFormat ddf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				    
				    final int MAXATTACHNAMELENGTH = 300;
				    String sname=info.getName();
				    if( sname.length() > MAXATTACHNAMELENGTH ) sname = sname.substring(0,MAXATTACHNAMELENGTH) + "...";
	%>

	
			
			      <div class="info">
			  
					<p class=" title bold-font changeLine"><%=info.getTitle() %></p>
					<p class=" changeLine"><a href="CheckHomepageExist.jsp?fullName=<%=info.getAuthor() %>"><%=info.getAuthor() %></a>
					
					
					&nbsp上传于&nbsp&nbsp<%=ddf.format(info.getTime()) %>.&nbsp&nbsp&nbsp大小&nbsp&nbsp&nbsp&nbsp<%=getPrintSize(info.getSize()) %> 
					&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp下载：
					<wiki:Permission permission="edit">
					<a href="DownLoadServlet?id=<%=info.getID() %>&fileName=<%=info.getName() %>"><%=info.getName() %></a>
					</wiki:Permission>
					<wiki:Permission permission="!edit">
					您没有下载权限
					</wiki:Permission>
					</p> 
				  </div>
				
		<%
	            }
	      }
	      else
	      {
	    //  System.out.println("AAcontent.jsp:ID==null");
	      }
	    %>
	    
<wiki:Content />

