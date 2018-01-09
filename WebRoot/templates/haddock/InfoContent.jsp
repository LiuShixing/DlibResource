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

<%@page import="java.sql.ResultSet"%>
<%@page import="dr.DBManager"%>
<%@page import="servlet.MyUtil"%>
<%@page import="servlet.ResourceInfo"%>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.auth.*" %>
<%@ page import="org.apache.wiki.auth.permissions.*" %>
<%@ page import="org.apache.wiki.attachment.*" %>
<%@ page import="org.apache.wiki.i18n.InternationalizationManager" %>
<%@ page import="org.apache.wiki.preferences.Preferences" %>
<%@ page import="org.apache.wiki.util.TextUtil" %>
<%@ page import="java.security.Permission" %>
<%@ taglib uri="http://jspwiki.apache.org/tags" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page language="java" import="java.util.*" contentType="text/html; charset=utf-8"%>
<fmt:setLocale value="${prefs.Language}" />
<fmt:setBundle basename="templates.default"/>
<%
  WikiContext c = WikiContext.findContext(pageContext);
  WikiPage wikiPage = c.getPage();
  int attCount = c.getEngine().getAttachmentManager().listAttachments( c.getPage() ).size();
  String attTitle = LocaleSupport.getLocalizedMessage(pageContext, "attach.tab");
  if( attCount != 0 ) attTitle += " (" + attCount + ")";

  String parm_renameto = (String)request.getParameter( "renameto" );
  if( parm_renameto == null ) parm_renameto = wikiPage.getName();

  String creationAuthor ="";

  //FIXME -- seems not to work correctly for attachments !!
  WikiPage firstPage = c.getEngine().getPage( wikiPage.getName(), 1 );
  if( firstPage != null )
  {
    creationAuthor = firstPage.getAuthor();

    if( creationAuthor != null && creationAuthor.length() > 0 )
    {
      creationAuthor = TextUtil.replaceEntities(creationAuthor);
     
    }
    else
    {
      creationAuthor = Preferences.getBundle( c, InternationalizationManager.CORE_BUNDLE ).getString( "common.unknownauthor" );
      
    }
  }
  
  //修改
  {    
  		if(wikiPage.getName().getBytes()[0] == '1')
  		{
	       HttpSession hsess = request.getSession();
	       String id = (String)hsess.getAttribute(MyUtil.REQ_RES_ID);
	       ResourceInfo resInfo=null;
	       if(id!=null)
	       {
		       ServletContext servletContext = request.getServletContext();
		       if(servletContext!=null)
		       {	       
		           Map<String,ResourceInfo> resMp=(Map<String,ResourceInfo>)servletContext.getAttribute(MyUtil.RESOURCE_INFO_MP);
	               if(resMp!=null)
	               {
	                  resInfo = resMp.get(id.toLowerCase());
	               }          
	           }     
	       }
	      
		   if(resInfo!=null &&creationAuthor.equals("unknown"))
		   {
		       creationAuthor=resInfo.getAuthor();
		   }
		   
	   }
	   else if(wikiPage.getName().getBytes()[0] == '2')
	   {
			String sql="select author from articles where id=?";
			DBManager db=new DBManager(sql);
			db.pst.setString(1, wikiPage.getName());
			ResultSet rs=db.pst.executeQuery();
			String author=null;
			if(rs.next())
			{
				author=rs.getString(1);
			}
			if(author != null)
			{
				creationAuthor = author;
			}
			rs.close();
			db.close();
	   }
	   if(creationAuthor.equals("unknown"))
	   {
	       creationAuthor="system";
	   }
  }

  int itemcount = 0;  //number of page versions
  try
  {
    itemcount = wikiPage.getVersion(); /* highest version */
  }
  catch( Exception  e )  { /* dont care */ }

  int pagesize = 20;
  int startitem = itemcount-1; /* itemcount==1-20 -> startitem=0-19 ... */

  String parm_start = (String)request.getParameter( "start" );
  if( parm_start != null ) startitem = Integer.parseInt( parm_start ) ;

  /* round to start of block: 0-19 becomes 0; 20-39 becomes 20 ... */
  if( startitem > -1 ) startitem = ( startitem / pagesize ) * pagesize;

  /* startitem drives the pagination logic */
  /* startitem=-1:show all; startitem=0:show block 1-20; startitem=20:block 21-40 ... */
%>
<div class="page-content">

<wiki:PageExists>

<wiki:PageType type="page">
  <div class="form-frame">
  <p>
  <fmt:message key='info.lastmodified'>
    <fmt:param><span class="badge"><wiki:PageVersion >1</wiki:PageVersion></span></fmt:param>
    <fmt:param>
      <a href="<wiki:DiffLink format='url' version='latest' newVersion='previous' />"
        title="<fmt:message key='info.pagediff.title' />" >
        <fmt:formatDate value="<%= wikiPage.getLastModified() %>" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" />
      </a>
    </fmt:param>
    <fmt:param><wiki:Author /></fmt:param>
  </fmt:message>
  <wiki:RSSImageLink mode="wiki"/>
  </p>

  <wiki:CheckVersion mode="notfirst">
  <p>
    <fmt:message key='info.createdon'>
      <fmt:param>
        <wiki:Link version="1">
          <fmt:formatDate value="<%= firstPage.getLastModified() %>" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" />
        </wiki:Link>
      </fmt:param>
      <fmt:param><%= creationAuthor %></fmt:param>
    </fmt:message>
  </p>
  </wiki:CheckVersion>
<%
   String pageName = request.getParameter("page");
   if(pageName!=null && !pageName.equals("help"))
   {
       WikiSession wikiSession = c.getWikiSession();
       String user=null;
       if(wikiSession!=null && wikiSession.getUserPrincipal()!=null)
       {
         user = wikiSession.getUserPrincipal().getName();
       }
       System.out.println("InfoContent.jsp:user="+user+" creationAuthor="+creationAuthor);
	   if(user==null || !user.equals(creationAuthor))
	   {
 %>
  <wiki:Permission permission="delete">
    <form action="<wiki:Link format='url' context='<%=WikiContext.DELETE%>' />"
           class="form-group"
              id="deleteForm"
          method="post" accept-charset="<wiki:ContentEncoding />" >
      <input class="btn btn-danger" type="submit" name="delete-all" id="delete-all"
        data-modal="+ .modal"
            value="删除" />
      <div class="modal"><fmt:message key='info.confirmdelete'/></div>
    </form>
  </wiki:Permission>
  <wiki:Permission permission="!delete">
    <p class="text-warning">只有授权用户才能删除</p>
  </wiki:Permission>
<%
       }else
       {  //资源上传者可以删除资源
%>
     <form action="<wiki:Link format='url' context='<%=WikiContext.DELETE%>' />"
           class="form-group"
              id="deleteForm"
          method="post" accept-charset="<wiki:ContentEncoding />" >
      <input class="btn btn-danger" type="submit" name="delete-all" id="delete-all"
        data-modal="+ .modal"
            value="删除" />
      <div class="modal"><fmt:message key='info.confirmdelete'/></div>
    </form>
  
<% 
       }
} 
%>
  </div>


  <div class="tabs">
    <h4 id="history">历史版本</h4>

    <wiki:SetPagination start="<%=startitem%>" total="<%=itemcount%>" pagesize="<%=pagesize%>" maxlinks="9"
                       fmtkey="info.pagination"
                         href='<%=c.getURL(WikiContext.INFO, wikiPage.getName(), "start=%s")%>' />

    <c:set var="first" value="<%= startitem %>"/>
    <c:set var="last" value="<%= startitem + pagesize %>"/>

    <div class="table-filter-sort-condensed-striped">
    <table class="table" >
      <tr>
        <th><fmt:message key="info.version"/></th>
        <th><fmt:message key="info.date"/></th>
        <th><fmt:message key="info.size"/></th>
        <th><fmt:message key="info.author"/></th>
       <%--  <th><fmt:message key="info.changes"/></th> --%>
        <th><fmt:message key="info.changenote"/></th>
      </tr>

      <wiki:HistoryIterator id="currentPage">
      <c:if test="${ first == -1 || ((currentPage.version > first ) && (currentPage.version <= last )) }">
      <tr>
        <td>
          <wiki:Link version="${currentPage.version}">
            <wiki:PageVersion/>
          </wiki:Link>
        </td>

	    <td class="nowrap" jspwiki:sortvalue="${currentPage.lastModified.time}">
        <fmt:formatDate value="${currentPage.lastModified}" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" />
        </td>

        <c:set var="pageSize"><wiki:PageSize /></c:set>
        <td class="nowrap" title="${pageSize} bytes">
          <%--<fmt:formatNumber value='${pageSize/1000}' maxFractionDigits='3' minFractionDigits='1'/>&nbsp;<fmt:message key="info.kilobytes"/>--%>
          <%= org.apache.commons.io.FileUtils.byteCountToDisplaySize( currentPage.getSize() ) %>
        </td>
        <c:if test="${ currentPage.version == 1  }"><td><%=creationAuthor %></td></c:if>
        <c:if test="${ currentPage.version !=1 }"><td><wiki:Author /></td></c:if>

     <%--    <td class="nowrap">
          <wiki:CheckVersion mode="notfirst">
            <wiki:DiffLink version="current" newVersion="previous"><fmt:message key="info.difftoprev"/></wiki:DiffLink>
            <wiki:CheckVersion mode="notlatest"> | </wiki:CheckVersion>
          </wiki:CheckVersion>
          <wiki:CheckVersion mode="notlatest">
            <wiki:DiffLink version="latest" newVersion="current"><fmt:message key="info.difftolast"/></wiki:DiffLink>
          </wiki:CheckVersion>
        </td> --%>

        <c:set var="changenote" value="<%= (String)currentPage.getAttribute( WikiPage.CHANGENOTE ) %>" />
        <td class="changenote">${changenote}</td>

      </tr>
      </c:if>
      </wiki:HistoryIterator>

    </table>
    </div>
    ${pagination}

   

    <%-- DIFF section --%>
    <wiki:CheckRequestContext context='diff'>
      <h4 data-activePane id="diff">Difference</h4>
      <wiki:Include page="DiffTab.jsp"/>
    </wiki:CheckRequestContext>

  </div>

</wiki:PageType>


<%-- part 2 : attachments --%>
<wiki:PageType type="attachment">
<%
  int MAXATTACHNAMELENGTH = 30;
%>
<c:set var="progressId" value="<%= c.getEngine().getProgressManager().getNewProgressIdentifier() %>" />
<wiki:Permission permission="upload">

  <form action="<wiki:Link jsp='attach' format='url' absolute='true'><wiki:Param name='progressid' value='${progressId}'/></wiki:Link>"
         class="accordion-close"
            id="uploadform"
        method="post" accept-charset="<wiki:ContentEncoding/>"
       enctype="multipart/form-data" >

  <%-- Do NOT change the order of wikiname and content, otherwise the
       servlet won't find its parts. --%>

  <h4><fmt:message key="info.uploadnew"/></h4>

    <div class="form-group">
      <label class="control-label form-col-20" for="files"><fmt:message key="attach.add.selectfile"/></label>
      <ul class="list-group form-col-50">
        <li class="list-group-item droppable">
          <label>Select files <%--or drop them here!--%></label>
          <input type="file" name="files" id="files" size="60"/>
          <a class="hidden delete btn btn-danger btn-xs pull-right">Delete</a>
        </li>
      </ul>
    </div>
    <div class="form-group">
      <label class="control-label form-col-20" for="changenote"><fmt:message key="attach.add.changenote"/></label>
      <input class="form-control form-col-50" type="text" name="changenote" id="changenote" maxlength="80" size="60" />
    </div>
    <div class="form-group">
    <input type="hidden" name="nextpage" value="<wiki:Link context='info' format='url'/>" /><%-- *** --%>
    <input type="hidden" name="page" value="<wiki:Variable var="pagename"/>" />
    <input class="btn btn-primary form-col-offset-20 form-col-50"
           type="submit" name="upload" id="upload" disabled="disabled" value="<fmt:message key='attach.add.submit'/>" />
    <%--<input type="hidden" name="action" value="upload" />--%>
    </div>
    <div class="hidden form-col-offset-20 form-col-50 progress progress-striped active">
      <div class="progress-bar" data-progressid="${progressId}" style="width: 100%;"></div>
    </div>

  </form>
</wiki:Permission>
<wiki:Permission permission="!upload">
  <div class="block-help bg-warning"><fmt:message key="attach.add.permission"/></div>
</wiki:Permission>


<form action="<wiki:Link format='url' context='<%=WikiContext.DELETE%>' ><wiki:Param name='tab' value='attach' /></wiki:Link>"
           class="form-group"
              id="deleteForm"
          method="post" accept-charset="<wiki:ContentEncoding />" >

  <c:set var="parentPage"><wiki:ParentPageName/></c:set>
  <a class="btn btn-primary" href="<wiki:Link page='${parentPage}' format='url' />" >
    <fmt:message key="info.backtoparentpage" >
      <fmt:param><span class="badge">${parentPage}</span></fmt:param>
    </fmt:message>
  </a>

  <wiki:Permission permission="delete">
    <input class="btn btn-danger" type="submit" name="delete-all" id="delete-all"
      data-modal="+ .modal"
           value="<fmt:message key='info.deleteattachment.submit' />" />
    <div class="modal"><fmt:message key='info.confirmdelete'/></div>
  </wiki:Permission>
</form>

<%-- TODO why no pagination here - number of attach versions of one page limited ?--%>
<%--<h4><fmt:message key='info.attachment.history' /></h4>--%>
  <div class="slimbox-attachments table-filter-sort-condensed-striped">
  <table class="table">
    <tr>
      <th><fmt:message key="info.version"/></th>
      <th><fmt:message key="info.attachment.type"/></th>
      <th><fmt:message key="info.attachment.name"/></th>
      <th><fmt:message key="info.size"/></th>
      <th><fmt:message key="info.date"/></th>
      <th><fmt:message key="info.author"/></th>
      <%--
      <wiki:Permission permission="upload">
         <th><fmt:message key="info.actions"/></th>
      </wiki:Permission>
      --%>
      <th><fmt:message key="info.changenote"/></th>
    </tr>

    <wiki:HistoryIterator id="att"><%-- <wiki:AttachmentsIterator id="att"> --%>
    <tr>

      <td><wiki:LinkTo version="${att.version}"><wiki:PageVersion /></wiki:LinkTo></td>

      <%-- see styles/fontjspwiki/icon.less : icon-file-<....>-o  --%>
      <c:set var="parts" value="${fn:split(att.fileName, '.')}" />
      <c:set var="type" value="${ fn:length(parts)>1 ? parts[fn:length(parts)-1] : ''}" />
      <td class="attach-type"><span class="icon-file-${type}-o">${type}</span></td>

      <td class="attach-name">${att.fileName}</td>

      <td class="nowrap" title="${att.size} bytes">
        <%-- <fmt:formatNumber value='${att.size/1024.0}' maxFractionDigits='1' minFractionDigits='1'/>&nbsp;<fmt:message key="info.kilobytes"/> --%>
        <%= org.apache.commons.io.FileUtils.byteCountToDisplaySize( att.getSize() ) %>
      </td>

	  <td class="nowrap" jspwiki:sortvalue="${att.lastModified.time}">
	    <fmt:formatDate value="${att.lastModified}" pattern="${prefs.DateFormat}" timeZone="${prefs.TimeZone}" />
	  </td>

      <td><wiki:Author /></td>
      <%--
      // FIXME: This needs to be added, once we figure out what is going on.
      <wiki:Permission permission="upload">
         <td>
            <input type="button"
                   value="Restore"
                   url="<wiki:Link format='url' context='<%=WikiContext.UPLOAD%>'/>"/>
         </td>
      </wiki:Permission>
      --%>

      <c:set var="changenote" value="<%= (String)att.getAttribute( WikiPage.CHANGENOTE ) %>" />
      <td class="changenote">${changenote}</td>

    </tr>
    </wiki:HistoryIterator><%-- </wiki:AttachmentsIterator> --%>

  </table>
  </div>

</wiki:PageType>

</wiki:PageExists>

<wiki:NoSuchPage>
  <div class="danger">
  <fmt:message key="common.nopage">
    <fmt:param><a class="createpage" href="<wiki:EditLink format='url'/>"><fmt:message key="common.createit"/></a></fmt:param>
  </fmt:message>
  </div>
</wiki:NoSuchPage>

</div>
