<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	
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
	System.out.println(totalRowStmt+"start_with_connect_by_prior_list param totalRowStmt");
	
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	
	int endRow = beginRow + (rowPerPage-1);
	// endRow에 대한 에러 방지(totalRow를 넘지않도록)
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	// 페이지네비게이션에 표기될 페이지 개수
	int pagePerPage = 10;
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	int minPage = ((currentPage-1) / rowPerPage) * rowPerPage + 1;
	int maxPage = minPage + (pagePerPage-1);
	// maxPage가 lagePage를 넘지 않도록
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	
	// 계층쿼리(start with ... connect by prior)
	/* 
		select 번호, 레벨, 계층별빈칸수, 매니저ID, 계층별구분 
		from (select rownum 번호, 레벨, 계층별빈칸수, 매니저ID, 계층별구분 
		from (select level 레벨, lpad(' ', level-1) || first_name 계층별빈칸수, manager_id 매니저ID, sys_connect_by_path(first_name, '/') 계층별구분 
		from employees start with manager_id is null connect by prior employee_id = manager_id)) 
		where 번호 between ? and ?;
	*/
	
	String sql = "select 번호, 레벨, 계층별빈칸수, 매니저ID, 계층별구분"
			+ " from (select rownum 번호, 레벨, 계층별빈칸수, 매니저ID, 계층별구분"
			+ " from (select level 레벨, lpad(' ', level-1) || first_name 계층별빈칸수, manager_id 매니저ID, sys_connect_by_path(first_name, '/') 계층별구분"
			+ " from employees start with manager_id is null connect by prior employee_id = manager_id))"
			+ " where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", rs.getInt("번호"));
		m.put("레벨", rs.getInt("레벨"));
		m.put("계층별빈칸수", rs.getString("계층별빈칸수"));
		m.put("매니저ID", rs.getString("매니저ID"));
		m.put("계층별구분", rs.getString("계층별구분"));
		list.add(m);
	}
	System.out.println(list.size()+"start_with_connect_by_prior_list param list.size()");
	
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h2>rank()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>레벨</td>
			<td>계층별빈칸수</td>
			<td>매니저ID</td>
			<td>계층별구분</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(Integer)m.get("레벨")%></td>
				<td><%=(String)m.get("계층별빈칸수")%></td>
				<td><%=(String)m.get("매니저ID")%></td>
				<td><%=(String)m.get("계층별구분")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
</body>
</html>