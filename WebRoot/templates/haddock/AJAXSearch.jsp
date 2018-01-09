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

<%@page import="servlet.ResourceInfo"%>
<%@page import="servlet.MyUtil"%>
<%@page import="search.MySearch"%>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.wiki.search.SearchResult" %>
<%@ page import="org.apache.wiki.ui.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Collection" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*"
	contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%!
  public void jspInit()
  {
    wiki = WikiEngine.getInstance( getServletConfig() );
  }
  Logger log = Logger.getLogger("JSPWikiSearch");
  WikiEngine wiki;
%>
<%
  /* ********************* actual start ********************* */
  /* FIXME: too much hackin on this level -- should better happen in toplevel jsp's */
  /* Create wiki context and check for authorization */
  WikiContext wikiContext = wiki.createContext( request, WikiContext.FIND );
  if(!wiki.getAuthorizationManager().hasAccess( wikiContext, response )) return;

  String query = request.getParameter( "query");

  if( (query != null) && ( !query.trim().equals("") ) )
  {
    try
    {
   //   Collection list = wiki.findPages( query, wikiContext );
    
  
      //修改
      Map<String,ResourceInfo> pageMap = (Map<String,ResourceInfo>)request.getServletContext().getAttribute(MyUtil.RESOURCE_INFO_MP);
      MySearch mySearch = new MySearch();
      
      Collection  list =mySearch.findPages( query, wikiContext ,wiki,pageMap);
      if(list==null)System.out.println("AJAXSearch.jsp:list=null");


      //  Filter down to only those that we actually have a permission to view
      AuthorizationManager mgr = wiki.getAuthorizationManager();

      ArrayList items = new ArrayList();

      for( Iterator i = list.iterator(); i.hasNext(); )
      {
        SearchResult r = (SearchResult)i.next();

        WikiPage p = r.getPage();


        PagePermission pp = new PagePermission( p, PagePermission.VIEW_ACTION );

        try
        {
          if( mgr.checkPermission( wikiContext.getWikiSession(), pp ) )
          {
            items.add( r );
          }
        }
        catch( Exception e ) { log.error( "Searching for page "+p, e ); }
      }

      pageContext.setAttribute( "searchresults", items, PageContext.REQUEST_SCOPE );
    }
    catch( Exception e )
    {
       wikiContext.getWikiSession().addMessage( e.getMessage() );
    }
  }
%>
<%
  int startitem = 0; // first item to show
  int maxitems = 20; // number of items to show in result

  String parm_start    = request.getParameter( "start");
  if( parm_start != null ) startitem = Integer.parseInt( parm_start ) ;

  Collection list = (Collection)pageContext.getAttribute( "searchresults", PageContext.REQUEST_SCOPE );
  if( startitem == -1 ) maxitems = list.size(); //show all
%>

<wiki:SearchResults>

  <h4><fmt:message key="find.heading.results"><fmt:param><c:out value="${param.query}"/></fmt:param></fmt:message></h4>

  <p>
  <fmt:message key="find.externalsearch"/>
    <a class="external"
        href="http://www.google.com/search?q=<c:out value='${param.query}'/>"
        title="Google Search '<c:out value='${param.query}'/>'"
       target="_blank">Google</a><img class="outlink" src="images/out.png" alt="" />
    |
    <a class="external"
        href="http://en.wikipedia.org/wiki/Special:Search?search=<c:out value='${param.query}'/>"
        title="Wikipedia Search '<c:out value='${param.query}'/>'"
       target="_blank">Wikipedia</a><img class="outlink" src="images/out.png" alt="" />
  </p>

  <wiki:SetPagination start="${param.start}" total="<%=list.size()%>" pagesize="20" maxlinks="9"
                     fmtkey="info.pagination"
                    onclick="$('start').value=s; SearchBox.runfullsearch();" />
          <!-- 修改过，原来是$('start').value=%s -->

    <div class="graphBars">
    <div class="zebra-table">
    <table class="wikitable  table-striped" >

      <tr>
      	<th align="left">类型</th>
         <th align="left">标题</th>
         <th align="left"><fmt:message key="find.results.score"/></th>
      </tr>

      <wiki:SearchResultIterator id="searchref" start="${param.start}" maxItems="<%=maxitems%>">
      <%
      String st = "资源";
      if(searchref.getContexts()[1].getBytes()[0] == '1')
      {
      	st = "资源";
  	 %>
  	 <tr>
  	 <td><%=st %><%-- <wiki:PageName/> --%></td>
  	  <wiki:UserCheck status="authenticated">
        <td><wiki:LinkTo><%=searchref.getContexts()[0] %><%-- <wiki:PageName/> --%></wiki:LinkTo></td>
        </wiki:UserCheck>
        
        <wiki:UserCheck status="notAuthenticated">
        <td><wiki:Permission permission="login">
		 <a href="<wiki:Link jsp='Login.jsp' format='url'><wiki:Param 
		         name='redirect' value="登陆"/></wiki:Link>" 
		        class="action login"
		        title="登陆以查看资源">
			<%=searchref.getContexts()[0] %>
		</a>
	</wiki:Permission></td>
        </wiki:UserCheck>
        
        <td><span class="gBar"><%= searchref.getScore() %></span></td>
        </tr>
  	 <% 	
      
      }
      else if(searchref.getContexts()[1].getBytes()[0] == '2')
      {
      	st = "文章";
      	
      %>
       <tr>
        <td><%=st %><%-- <wiki:PageName/> --%></td>
        
        <td><wiki:LinkTo><%=searchref.getContexts()[0] %><%-- <wiki:PageName/> --%></wiki:LinkTo></td>
        
        <td><span class="gBar"><%= searchref.getScore() %></span></td>
      </tr>
      <% 
      }
       %>
     

	  <c:if test="${param.details == 'on'}">
<%
        String[] contexts = searchref.getContexts();
        if( (contexts != null) && (contexts.length > 0) )
        {
%>
      <tr class="odd" >
        <td class="fragment" colspan="2">
<%
          for (int i = 0; i < contexts.length; i++)
          {
%>
            <%= (i > 0 ) ? "<span class='fragment_ellipsis'> ... </span>" : ""  %>
            <%= contexts[i]  %>
<%
          }
%>
         </td>
       </tr>
<%
        }
%>
	  </c:if><%-- details --%>
      </wiki:SearchResultIterator>

      </table>

      <wiki:IfNoSearchResults>
        <p class="warning">找不到结果。可能没有您要找的。</p>
      </wiki:IfNoSearchResults>


    </div>
    </div>
    ${pagination}

   </wiki:SearchResults>
