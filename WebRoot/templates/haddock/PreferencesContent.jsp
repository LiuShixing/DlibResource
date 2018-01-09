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

<%@page import="org.apache.wiki.i18n.InternationalizationManager"%>
<%@page import="org.apache.wiki.auth.GroupPrincipal"%>
<%@page import="org.apache.wiki.preferences.Preferences"%>
<%@page import="java.security.Principal"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.ui.*" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>

<%!
     public String printGroups( WikiContext context )
    {
        Principal[] roles = context.getWikiSession().getRoles();
        List<String> tempRoles = new ArrayList<String>();
        ResourceBundle rb = Preferences.getBundle( context, InternationalizationManager.CORE_BUNDLE );
        
        for ( Principal role : roles )
        {
            if( role instanceof GroupPrincipal )
            {
                tempRoles.add( role.getName() );
            }
        }
        if ( tempRoles.size() == 0 )
        {
            return rb.getString("userprofile.nogroups");
        }

        StringBuilder sb = new StringBuilder();
        for ( int i = 0; i < tempRoles.size(); i++ )
        {
            String name = tempRoles.get( i );

            sb.append( name );
            if ( i < ( tempRoles.size() - 1 ) )
            {
                sb.append(',');
                sb.append(' ');
            }

        }
        return sb.toString();
    }
 %>
<div class="page-content">

<wiki:UserCheck status="notAuthenticated">
  <wiki:Include page="PreferencesTab.jsp" />
</wiki:UserCheck>

<wiki:UserCheck status="authenticated">
<div class="tabs">

  <h3 id="section-prefs">
    <fmt:message key="prefs.tab.prefs" />
  </h3>
  <wiki:Include page="PreferencesTab.jsp" />

  <wiki:Permission permission="editProfile">
  <wiki:UserProfile property="exists">
    <c:set var="profileTab" value="${param.tab == 'profile' ? 'data-activePane' : ''}"/>
    <h3 ${profileTab} id="section-profile"><fmt:message key="prefs.tab.profile"/></h3>
    <wiki:Include page="ProfileTab.jsp" />
    <%-- <%=LocaleSupport.getLocalizedMessage(pageContext, "prefs.tab.profile")%> --%>
  </wiki:UserProfile>
  </wiki:Permission>

  <wiki:Permission permission="createGroups"><%-- use WikiPermission --%>
    <c:set var="groupTab" value="${param.tab == 'groups' ? 'data-activePane' : ''}"/>
    <wiki:CheckRequestContext context='viewGroup|editGroup|createGroup'>
       <c:set var="groupTab">data-activePane</c:set>
    </wiki:CheckRequestContext>
    <h3 ${groupTab} id="section-groups"><fmt:message key="group.tab" /></h3>
    <wiki:Include page="GroupTab.jsp" />
  </wiki:Permission>
  

<%
     WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
    // Create wiki context and check for authorization
     WikiContext wikiContext = wiki.createContext( request, WikiContext.ADMIN );
     String groups=printGroups(wikiContext);
  //   System.out.println("PreferenceContent.jsp:groups="+groups);
     if(groups ==null)groups="";
     String [] gs = groups.split(",");
     boolean isAdmin=false;
     for(String g:gs)
     {
         if(g.trim().equals("Admin"))
         {
            isAdmin=true;
            break;
         }
     }
     if(isAdmin)
     {
 %>
  
    <h3  id="section-users">用户管理</h3>
    <wiki:Include page="AAuserManagementTab.jsp" />
    
    <h3  id="section-label">标签管理</h3>
    <wiki:Include page="AAlabelManagementTab.jsp" />

<%
   }
 %>
 
 
</div>
</wiki:UserCheck>

</div>