package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.wiki.WikiEngine;

/**
 * Servlet implementation class getProgressServlet
 */
public class getProgressServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public getProgressServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		response.setCharacterEncoding("utf-8");
		String id= request.getParameter("id");
		WikiEngine wiki = WikiEngine.getInstance( getServletConfig() );
		int percent=0;
		try{
		   percent=wiki.getProgressManager().getProgress(id);
		}catch(IllegalArgumentException e)
		{
			
		}
		
		PrintWriter out=response.getWriter(); 
		
		out.print(percent);
		
		out.flush();
		out.close();
	}

}
