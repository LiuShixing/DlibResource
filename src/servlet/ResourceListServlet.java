package servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.wiki.WikiEngine;
import org.apache.wiki.api.exceptions.ProviderException;
import org.apache.wiki.attachment.Attachment;
import org.apache.wiki.attachment.AttachmentManager;

/**
 * Servlet implementation class ResourceListServlet
 */
public class ResourceListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ResourceListServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		WikiEngine wiki = WikiEngine.getInstance(getServletConfig());
		AttachmentManager attachmentManager = wiki.getAttachmentManager();
		ArrayList<Attachment> allAtts=null;
		try
		{
			allAtts = (ArrayList<Attachment>) attachmentManager.getAllAttachments();
		} catch (ProviderException e)
		{
			e.printStackTrace();
		}

		String attType= request.getParameter("attType");
		if(attType == null)attType="all";
		
		ArrayList<Attachment> needAtts = new ArrayList<Attachment>();
		for (Attachment att : allAtts) {
			String t = (String)att.getAttribute("attType");
			if(t==null)t="other";
			if(t.equals(attType))
			{
				needAtts.add(att);
			}
		}
		
		String itemsPerPageString = request.getParameter("itemsPerPage");
		String currPageString = request.getParameter("currPage");
		int currPage=1;
		if(currPageString==null)currPageString="1";
		currPage=Integer.parseInt(currPageString);
		
		int itemsPerPage=0;
		if(itemsPerPageString==null)itemsPerPage = 5;
		
		int total = needAtts.size();
		int totalPage = total/itemsPerPage;
		if(total % itemsPerPage != 0){
		    totalPage += 1;
		}
		Vector<Integer> pageArr = new Vector<Integer>();
		int start = 1;
		if(currPage >= 10){
		     start = currPage/10 * 10;
		 }
		int num = start;
		while(!(num > totalPage || num > start + 10)){
		     pageArr.add(new Integer(num));
		    ++num;
		}
		
		ArrayList<Attachment> showAtts = new ArrayList<Attachment>();
		int index = itemsPerPage*(currPage-1);
		while (index<total && index<itemsPerPage*currPage)
		{
			showAtts.add(needAtts.get(index));
		}
		
		HttpSession session = request.getSession();
		if(session!=null)
		{
			session.setAttribute("pageArr", pageArr);
			session.setAttribute("showAtts", showAtts);
		}
		
		response.sendRedirect("AAMyHome.jsp?tag="+attType+"&currPage="+currPage+"&totalPage="+totalPage+"&itemsPerPage="+itemsPerPage);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
