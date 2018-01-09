package servlet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dr.DBManager;



/**
 * Servlet implementation class ApplicationInitServlet
 */
public class ApplicationInitServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ApplicationInitServlet()
	{
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException
	{
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException
	{
		// TODO Auto-generated method stub
	}

	@Override
	public void destroy()
	{
	
		super.destroy();
	}

	@SuppressWarnings("unchecked")
	@Override
	public void init() throws ServletException
	{
		
		
		
		ServletContext application = getServletContext();
		String path=application.getRealPath("/");
		System.out.println(path);
		
		File file = new File(path+"/WEB-INF/resourceCount.txt");
		Integer resourceCount = 0;
		if (!file.exists())
		{
			try
			{
				file.createNewFile();

			} catch (IOException e)
			{

				e.printStackTrace();
			}
		}
		try
		{
			InputStreamReader is = new InputStreamReader(new FileInputStream(
					file));
			BufferedReader bReader = new BufferedReader(is);
			String lineString = bReader.readLine();
			if (lineString != null && lineString.length() > 0)
			{
				resourceCount = Integer.valueOf(lineString);
			}

			bReader.close();
			is.close();
			
			
			
			
			
			 
			File mpf =new File(MyUtil.PAGE_DIR +"fileNameMap.ob");
			Map<String, ResourceInfo> mp=null;
			if(mpf.exists())
			{
		        FileInputStream in;
		        try {
		            in = new FileInputStream(mpf);
		            ObjectInputStream objIn=new ObjectInputStream(in);
		            mp=(HashMap<String, ResourceInfo>)objIn.readObject();
		            objIn.close();
		            System.out.println("read object success!");
		        } catch (IOException e) {
		            System.out.println("read object failed");
		            e.printStackTrace();
		        } catch (ClassNotFoundException e) {
		            e.printStackTrace();
		        }
			}
			if (mp == null)
			{
				mp=new HashMap<String, ResourceInfo>();
			}
			//保存mp
			application.setAttribute(MyUtil.RESOURCE_INFO_MP, mp);
		

		} catch (IOException e)
		{

			e.printStackTrace();
		}

		
		application.setAttribute("resourceCount", resourceCount);
		System.out.println("ApplicationInitServlet:resourceCount="
				+ resourceCount);
		
		
		
		
		
		
		//--------------------------------------------------
	/*	DBManager db=new DBManager("select * from tb");
		try
		{
			ResultSet rs=db.pst.executeQuery();
			while (rs.next())
			{
				System.out.println(rs.getInt(1));;
				System.out.println(rs.getInt(2));;
			}
		} catch (SQLException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		db.close();*/
		super.init();
	}

}
