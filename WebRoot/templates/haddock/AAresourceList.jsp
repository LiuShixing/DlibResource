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


<div class="resourceList">


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

        ServletContext app = request.getServletContext();
        
        if(app==null)
        {
           System.out.println("ResourceList.jsp:app==null");
        }
       
        Map<String,ResourceInfo> mp=(Map<String,ResourceInfo>)app.getAttribute(MyUtil.RESOURCE_INFO_MP);
        
        if(mp==null)
        {
           System.out.println("ResourceList.jsp:mp==null");
        }
        
       	Map<String,String> m = new HashMap<String,String>();
		
		m.put("0","deeplearning");
		m.put("1","kg");
		m.put("2","med");
		m.put("3","edu");
		m.put("4","other");
		
		Map<String,String> m_name = new HashMap<String,String>();
		
		m_name.put("0","深度学习");
		m_name.put("1","知识图谱");
		m_name.put("2","医疗");
		m_name.put("3","教育");
		m_name.put("4","其他");
					
		String resType= request.getParameter("tag");
		WikiEngine wikiEngine = WikiEngine.getInstance( getServletConfig() );
		
		ArrayList<ResourceInfo> needRes = new ArrayList<ResourceInfo>();
		
		Iterator<Entry<String,ResourceInfo>> it = mp.entrySet().iterator(); 
		ArrayList<String> deleteRes = new ArrayList<String>();
		while(it.hasNext())
		{
			Map.Entry<String,ResourceInfo> entry = it.next();
			ResourceInfo info = entry.getValue();
		   if(!wikiEngine.pageExists( info.getID() ))
           {
               deleteRes.add(info.getID());
               continue;
           }
			
			if((resType==null || resType.equals("all")) ||m.get(info.getType()).equals(resType) )
			{ 
				needRes.add(info);
			}
		}
		
	    synchronized(MyUtil.mapLock)
        {
           for(String id:deleteRes)
           {
              mp.remove(id);
           }
        }	
		
		Collections.sort(needRes, new Comparator<ResourceInfo>(){
			  public int compare(ResourceInfo r1,ResourceInfo r2){
			      
			      return r2.getTime().compareTo(r1.getTime());
			  
			  }
			
			}
		);
		
		
		String itemsPerPageString = request.getParameter("itemsPerPage");
		String currPageString = request.getParameter("currPage");
		int currPage=1;
		if(currPageString==null)currPageString="1";
		currPage=Integer.parseInt(currPageString);
		
		int itemsPerPage=0;
		if(itemsPerPageString==null)itemsPerPage = MyUtil.LIST_COUNT;
		
		int total = needRes.size();
		int totalPage = total/itemsPerPage;
		if(total % itemsPerPage != 0){
		    totalPage += 1;
		}
		Vector<Integer> pageArr = new Vector<Integer>();
		int start = 1;
		
		final int NUM=10;
		if(currPage >= NUM){
		     start = currPage/NUM * NUM;
		 }
		int num = start;
		while(!(num > totalPage || num > start + NUM)){
		     pageArr.add(new Integer(num));
		    ++num;
		}
	 	
	 	ArrayList<ResourceInfo> showRes = new ArrayList<ResourceInfo>();
		
		int index = itemsPerPage*(currPage-1);
		while (index<total && index<itemsPerPage*currPage)
		{
			showRes.add(needRes.get(index));
			index++;
		} 
		
		if(showRes.size() ==0)
		{
 %>
   <div class="error text-align-center">没有资源</div>
 <%
        }else{
  %>
 
 
 <table  id="resourceTable" class="hovertable">
  <tr>
    <th width="17%" ><div class="table_center">上传日期</div></th>
    <th width="60%" ><div class="table_center">资源</div></th>
    <th width="10%"  id="resourceSize"><div class="table_center">大小</div></th>
    <th width="22%"  ><div class="table_center">上传人</div></th>
  </tr>
  
 <%
    
    String goPage="Home.jsp";
  
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    final int MAXATTACHNAMELENGTH=400;
    
    for(ResourceInfo info:showRes)
    {
       String sname =info.getTitle();
      
      if( sname.length() > MAXATTACHNAMELENGTH ) sname = sname.substring(0,MAXATTACHNAMELENGTH) + "...";
  %>
	<tr>
    <td class="table_center"><%=df.format(info.getTime())%> </td>
    <td class="resourceNameClass"><a class="resourceListType" href="Home.jsp?tag=<%=m.get(info.getType()) %>">[<%=m_name.get(info.getType()) %>]</a>
  
    <wiki:LinkTo page="<%=String.valueOf(info.getID()) %>">
		<%=sname %>
	</wiki:LinkTo>

	</td>
    <td class="table_center"><%=getPrintSize(info.getSize()) %> </td>
    <td class="table_center"><a href="CheckHomepageExist.jsp?fullName=<%=info.getAuthor() %>"><%=info.getAuthor() %></a> </td>
    </tr>
 <%
    }
  %>
 
</table>

 




<!-- ************************************ -->


 <%


%>

<div id="pageControl" align="center">


<!-- 上一页 按钮 -->
<%
if(total >itemsPerPage)
{
     if(currPage != 1)
     {
 %>
  <a href="<%=goPage %>?tag=<%=resType %>&currPage=<%=currPage-1 %>">
  <input type="button" value="上一页" class="mybutton myblue"/>
  </a>
 
 <%
     }else
     {
 %> 
 
  <input type="button" value="上一页" class="mybutton mywhite" disabled="disabled"/>
 
 <%
     }
  %> 
  
  
  
  <!-- 页数列表 -->
 <%
      for(int p:pageArr)
      {
           if(p==currPage)
           {
  %>
             <a href="<%=goPage %>?tag=<%=resType %>&currPage=<%=p %>" >
                <input type="button" value="<%=p %>" class="pageButton myblue"/>
             </a>
  <%
            }else{
   %>
              <a href="<%=goPage %>?tag=<%=resType %>&currPage=<%=p %>"  >
                 <input type="button" value="<%=p %>" class="pageButton mywhite"/>
              </a>
  
 <% 
         }
      }
  %>
  
 


 
<!-- 下一页 按钮 -->
<%
     if(currPage != totalPage)
     {
 %>
  <a href="<%=goPage %>?tag=<%=resType %>&currPage=<%=currPage+1 %>">
  <input type="button" value="下一页" class="mybutton myblue"/>
  </a>
 
 <%
     }else
     {
 %> 
  
       <input type="button" value="下一页" class="mybutton mywhite" disabled="disabled" />

 <%
     }
  %> 


<!-- 直接跳转 -->
共<%=totalPage %>页 -向<input type="text" id="jumpToText" value="<%=currPage %>" size="2" />页 
<a href="<%=goPage %>?tag=<%=resType %>&currPage= " id="jumpToLink">
 <input type="button" value="跳转" class="mybutton myblue" onclick="


        var page = document.getElementById('jumpToText').value;
	    var a=document.getElementById('jumpToLink');
	    if(!(Math.floor(page) == page) || page > <%=totalPage %> || page < 1 ){
	        alert('没有该页');
	        a.href='';
	       
	    }else{
	          a.href+=page;
	    }



"/>
</a>

<%
    }//end if(total >itemsPerPage)
 %>
</div>
 


<%
     } //end if no resource
 
 %>
 


</div>

