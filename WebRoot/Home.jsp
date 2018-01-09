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

<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.wiki.util.*" %>
<%@ page import="org.apache.commons.lang.time.StopWatch" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8" %>

<%!
    Logger log = Logger.getLogger("JSPwiki"); 
%>

<%
    WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
    // Create wiki context and check for authorization
    WikiContext wikiContext = wiki.createContext( request, WikiContext.VIEW );
    if(!wiki.getAuthorizationManager().hasAccess( wikiContext, response )) return;
    String pagereq = wikiContext.getName();

    // Redirect if request was for a special page
    String redirect = wikiContext.getRedirectURL( );
    /*
    public String getRedirectURL()
	Figure out to which page we are really going to. Considers special page names from the jspwiki.properties, and possible aliases. This method forwards requests to CommandResolver.getSpecialPageReference(String).
	Returns:
	A complete URL to the new page to redirect to
	Since:
	2.2
    */
    if( redirect != null )
    {
        response.sendRedirect( redirect );
        return;
    }
    
    StopWatch sw = new StopWatch();
    sw.start();
    WatchDog w = wiki.getCurrentWatchDog();
    /*
    public WatchDog getCurrentWatchDog()
	Returns a WatchDog for current thread.
	Returns:
	The current thread WatchDog.
	Since:
	2.4.92
	*/
    try {
        w.enterState("Generating VIEW response for "+wikiContext.getPage(),60);
    
        // Set the content type and include the response content
        response.setContentType("text/html; charset="+wiki.getContentEncoding() );
        String contentPage = wiki.getTemplateManager().findJSP( pageContext,
                                                                wikiContext.getTemplate(),
                                                                "AAhome.jsp" );
                                                                
         //       System.out.println("Home.jsp:contentPage="+contentPage);

%><wiki:Include page="<%=contentPage%>" /><%
    }
    finally
    {
        sw.stop();
        if( log.isDebugEnabled() ) log.debug("Total response time from server on page "+pagereq+": "+sw);
        w.exitState();
    }
%>

