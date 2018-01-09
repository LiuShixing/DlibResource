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

<%@page import="org.apache.wiki.auth.UserManager"%>
<%@page import="org.apache.wiki.auth.AuthorizationManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.ObjectOutputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="servlet.ResourceInfo"%>
<%@page import="servlet.MyUtil"%>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.util.HttpUtil" %>
<%@ page import="org.apache.wiki.tags.BreadcrumbsTag" %>
<%@ page import="org.apache.wiki.tags.BreadcrumbsTag.FixedQueue" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.wiki.util.TextUtil" %>
<%@ page import="org.apache.wiki.attachment.Attachment" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<%!
    Logger log = Logger.getLogger("JSPWiki");
%>

<%
        String loginName=request.getParameter("loginName");
      
        boolean issuccess=false;
        if(loginName!=null)
        {
              WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
            
			  if(wiki!=null && wiki.getUserManager()!=null)
			  {  
			        UserManager userMgr = wiki.getUserManager();  
		            userMgr.getUserDatabase().deleteByLoginName(loginName);
		            issuccess=true;
			  }
	 
        }
        
        if(issuccess)
        {
            response.sendRedirect("UserPreferences.jsp?#section-users");
        }
        else{
           response.sendRedirect("UserPreferences.jsp?&error=deletefail#section-users");
        }
%>

