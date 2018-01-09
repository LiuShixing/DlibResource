package dr;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import servlet.MyUtil;

public class DBManager
{
	 public Connection conn = null;  
	 public PreparedStatement pst = null;  
	public DBManager(String sql)
	{
		try {  
            Class.forName("org.apache.derby.jdbc.EmbeddedDriver").newInstance();//指定连接类型  
            conn = DriverManager.getConnection("jdbc:derby:"+MyUtil.DB_DIR);//获取连接  
            pst = conn.prepareStatement(sql);//准备执行语句  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
	}
	 public void close() {  
        try { 
        	if(pst!=null)
        		this.pst.close(); 
        	if(conn!=null)
        		this.conn.close();              
        } catch (SQLException e) {  
            e.printStackTrace();  
        }
    }
	 
	public static int incTodayCounter(){
		DBManager db = new DBManager("select vdate, vnum from visitorcounter where id = 1");
		ResultSet rs = null;
		try
		{
			rs = db.pst.executeQuery();
			if(rs.next()){
				Date beginDate = rs.getDate(1);
				int count = rs.getInt(2);
				Date nowDate = new Date();
				java.sql.Date date = null;
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy");
				int nowy = Integer.parseInt(sdf.format(nowDate));
				int beginy = Integer.parseInt(sdf.format(beginDate));
				if(nowy > beginy){
					count = 1;
					date = new java.sql.Date(new Date().getTime());
				}
				else {
					count += 1;
					date = new java.sql.Date(beginDate.getTime());
				}
				rs.close();
				db.close();
				
				DBManager db2 = new DBManager("update visitorcounter set vnum = ?,vdate = ? where id = 1");
				db2.pst.setInt(1, count);
				db2.pst.setDate(2, date);
				db2.pst.executeUpdate();
				
				db2.close();
				return count;
			}
			else{
				rs.close();
				db.close();
				DBManager db2 = new DBManager("insert into visitorcounter values(?,?,?)");
				db2.pst.setInt(1, 1);
				db2.pst.setDate(2, new java.sql.Date(new Date().getTime()));
				db2.pst.setInt(3, 1);
				db2.pst.executeUpdate();
				rs.close();
				db2.close();
			}
		} catch (Exception e)
		{
			e.printStackTrace();
		}finally{
			db.close();
		}
		return 1;
	}
	public static int getCount()
	{
		DBManager db = new DBManager("select vdate, vnum from visitorcounter where id = 1");
		ResultSet rs = null;
		try
		{
			rs = db.pst.executeQuery();
			if(rs.next()){
				int count = rs.getInt(2);
				return count;
			}
			rs.close();
		} catch (Exception e)
		{
			
		}finally{
			db.close();
		}
		return 1;
	}
	

}


/* create table labels(label varchar(50) primary key);
 * create table article_labels(artid varchar(50),label varchar(200));
 * 
 * create table papers(id varchar(50) primary key,title varchar(300),authors varchar(300)
 *  ,keywords varchar(200),info varchar(500),abstract varchar(3000),custom_info varchar(500));
 *  
 *  create table visitorcounter(id int primary key, vdate date, vnum int);
 */
