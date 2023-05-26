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
	System.out.println(totalRowStmt+"exists_not_exists_list param totalRowStmt");
	
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
	
	// where exist 연산자 -> 뒤의 서브쿼리 결과에 따라 참 거짓을 판별한다. 
	// JOIN은 두테이블을 합친 결과셋을 where exist 메인쿼리에 사용된 테이블만 결과셋으로 사용
	/* 
		SELECT 번호, 직원ID, 성 FROM (SELECT ROWNUM 번호, 직원ID, 성 
		FROM (select e.employee_id 직원ID, e.first_name 성 from employees e 
		where exists (select * from departments d where d.department_id = e.department_id))) 
		WHERE 번호 BETWEEN 31 AND 40;
	*/
	
	String existsSql = "SELECT 번호, 직원ID, 성 FROM (SELECT ROWNUM 번호, 직원ID, 성 " 
			+ " FROM (select e.employee_id 직원ID, e.first_name 성 from employees e"
			+ " where exists (select * from departments d where d.department_id = e.department_id)))"
			+ " where 번호 between ? and ?";
	PreparedStatement existsStmt = conn.prepareStatement(existsSql);
	existsStmt.setInt(1, beginRow);
	existsStmt.setInt(2, endRow);
	ResultSet existsRs = existsStmt.executeQuery();
	ArrayList<HashMap<String, Object>> existsList = new ArrayList<>();
	while(existsRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호", existsRs.getInt("번호"));
		m.put("직원ID", existsRs.getInt("직원ID"));
		m.put("성", existsRs.getString("성"));
		existsList.add(m);
	}
	System.out.println(existsList.size()+"exists_not_exists_list param existsList.size()");
	
	// where not exist 연산자
	/* 
		SELECT 번호, 직원ID, 성 FROM (SELECT ROWNUM 번호, 직원ID, 성 
		FROM (select e.employee_id 직원ID, e.first_name 성 from employees e 
		where not exists (select * from departments d where d.department_id = e.department_id))) 
		WHERE 번호 BETWEEN 31 AND 40;
	*/
	
	String notExistsSql = "SELECT 번호, 직원ID, 성 FROM (SELECT ROWNUM 번호, 직원ID, 성 " 
			+ " FROM (select e.employee_id 직원ID, e.first_name 성 from employees e"
			+ " where not exists (select * from departments d where d.department_id = e.department_id)))"
			+ " where 번호 between ? and ?";
	PreparedStatement notExistsStmt = conn.prepareStatement(notExistsSql);
	notExistsStmt.setInt(1, beginRow);
	notExistsStmt.setInt(2, endRow);
	ResultSet notExistsRs = notExistsStmt.executeQuery();
	ArrayList<HashMap<String, Object>> notExistsList = new ArrayList<>();
	while(notExistsRs.next()) {
		HashMap<String, Object> m2 = new HashMap<>();
		m2.put("번호", notExistsRs.getInt("번호"));
		m2.put("직원ID", notExistsRs.getInt("직원ID"));
		m2.put("성", notExistsRs.getString("성"));
		notExistsList.add(m2);
	}
	System.out.println(notExistsList.size()+"exists_not_exists_list param notExistsList.size()");
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h2>exists()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>직원ID</td>
			<td>성</td>
		</tr>
		<%
			for(HashMap<String, Object> m : existsList) {
		%>
			<tr>
				<td><%=(Integer)m.get("번호")%></td>
				<td><%=(Integer)m.get("직원ID")%></td>
				<td><%=(String)m.get("성")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./exists_not_exists_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./exists_not_exists_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./exists_not_exists_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
		
	<h2>notExists()</h2>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>직원ID</td>
			<td>성</td>
		</tr>
		<%
			for(HashMap<String, Object> m2 : notExistsList) {
		%>
			<tr>
				<td><%=(Integer)m2.get("번호")%></td>
				<td><%=(Integer)m2.get("직원ID")%></td>
				<td><%=(String)m2.get("성")%></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			// 1페이지 뒤로갈 필요없음
			if(minPage > 1) {
		%>
				<a href="./exists_not_exists_list.jsp?currentPage=<%=minPage-1%>">이전</a>
		<% 
				}
		
			for(int i = minPage; i <=maxPage; i=i+1) {
				if(i == currentPage) {
		%>
					<span><%=i%></span>&nbsp;
		<% 			
				} else {
		%>
				<a href="./exists_not_exists_list.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<% 	
				}
			}
				// 같다면 마지막 페이지
				if(minPage != maxPage) {
		%>
				<!-- maxPage + 1 -->
				<a href="./exists_not_exists_list.jsp?currentPage=<%=maxPage+1%>">다음</a>
		<%
				}
		%>
</body>
</html>