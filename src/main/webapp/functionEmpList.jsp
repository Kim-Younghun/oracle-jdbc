<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%> 
<%
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}

	//DB연결
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@127.0.0.1:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn+"접속성공");
	
	int totalRow = 0;
	String totalRowSql = "SELECT count(*) FROM employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	System.out.println(totalRowStmt+"functionEmpList param totalRowStmt");
	
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage-1);
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	
	/*
	SELECT 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
	FROM
	    (SELECT rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, 
		salary 연봉, round(salary/12, 2) 급여, 
		hire_Date 입사날짜, extract(YEAR FROM hire_date) 입사년도 FROM employees) 
	WHERE 번호 BETWEEN ? AND ?;
	*/
	// sql 페이징 기능을 구현
	String sql = "SELECT 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 FROM (SELECT rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여,"
			+ " hire_Date 입사날짜, extract(YEAR FROM hire_date) 입사년도 FROM employees) WHERE 번호 BETWEEN ? AND ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rs.getInt("번호"));
		m.put("이름", rs.getString("이름"));
		m.put("이름첫글자", rs.getString("이름첫글자"));
		m.put("연봉", rs.getInt("연봉"));
		m.put("급여", rs.getDouble("급여"));
		m.put("입사날짜", rs.getString("입사날짜"));
		m.put("입사년도", rs.getInt("입사년도"));
		list.add(m);
	}
	System.out.println(list.size()+"functionEmpList param list.size()");
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>이름첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사날짜</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(String)m.get("이름")%></td>
				<td><%=(String)m.get("이름첫글자")%></td>
				<td><%=(Integer)m.get("연봉")%></td>
				<td><%=(Double)m.get("급여")%></td>
				<td><%=(String)m.get("입사날짜")%></td>
				<td><%=(Integer)m.get("입사년도")%></td>
			</tr>
		<%
			}
		%>
	</table>
	
		<%
			//페이지 네비게이션 페이징
			int pagePerPage = 10;
		/*	
			cp	minPage ~ maxPage
			1	1		~	10
			2	1		~	10
			10	1		~	10
			
			11	11		~	20
			12	11		~	20
			20	11		~	20
			
			(cp-1) / pagePerPage * pagePerPage + 1 --> minPage
			minPage + (pagePerPage - 1) --> maxPage
			maxPage > lastPage -->  maxPage = lastPage
		*/
			
		int lastPage = totalRow / rowPerPage;
		if(totalRow % rowPerPage != 0) {
			lastPage = lastPage + 1;
		}
		
		int minPage = ((currentPage-1) / pagePerPage) * pagePerPage +1;
		int maxPage = minPage + (pagePerPage - 1);
		// maxPage가 lastPage보다 커지지 않도록 한다.
		if(maxPage > lastPage) {
			maxPage = lastPage;
		}
		
				if(minPage > 1) {
		%>
				<a href="./functionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./functionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
		<%
				}
		%>
</body>
</html>