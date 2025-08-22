package service;

import java.util.List;
import java.util.Map;

import mapper.BookMapper;
import model.Book;
import org.springframework.stereotype.Service;

@Service
public class BookService {

	private final BookMapper bookMapper;

	public BookService(BookMapper bookMapper) {
		this.bookMapper = bookMapper;
	}

	public static class Page<T> {
		private final List<T> content;
		private final int page;           // 1-based
		private final int size;           // 이번 요청에서 가져온 개수(1p q없음=5, 그 외=10 또는 size)
		private final int totalPages;     // ✅ 커스텀 규칙으로 계산된 "항상 동일한" 총 페이지
		private final int totalElements;

		// 총 페이지를 직접 주입하는 생성자
		public Page(List<T> content, int page, int size, int totalElements, int totalPages) {
			this.content = content;
			this.page = page;
			this.size = size;
			this.totalElements = totalElements;
			this.totalPages = totalPages;
		}

		public List<T> getContent() { return content; }
		public int getPage() { return page; }
		public int getSize() { return size; }
		public int getTotalPages() { return totalPages; }
		public int getTotalElements() { return totalElements; }
	}

	public Page<Book> search(String q, int page, int size) {
		int safePage = Math.max(page, 1);
		boolean noQuery = (q == null || q.trim().isEmpty());

		// 이번 요청의 pageSize/offset
		int pageSize;
		int offset;
		if (noQuery) {
			if (safePage == 1) {
				pageSize = 5;
				offset   = 0;
			} else {
				pageSize = 10;
				offset   = 5 + (safePage - 2) * 10; // 2p=5, 3p=15, 4p=25 ...
			}
		} else {
			pageSize = size <= 0 ? 10 : Math.min(size, 50);
			offset   = (safePage - 1) * pageSize;
		}

		int total = bookMapper.count(q);

		// ✅ 총 페이지를 "항상 같은 규칙"으로 계산
		int effectiveTotalPages;
		if (noQuery) {
			if (total <= 5) {
				// 데이터가 0~5개면 페이지는 1페이지로 고정(빈 리스트여도 1로)
				effectiveTotalPages = 1;
			} else {
				// 1페이지(5개) 제외 나머지를 10개씩
				effectiveTotalPages = 1 + (int) Math.ceil((total - 5) / 10.0);
			}
		} else {
			// 검색 모드에서는 일반 규칙
			effectiveTotalPages = (int) Math.ceil(total / (double) pageSize);
		}

		// 정렬은 Mapper에서 반드시 고정(예: ORDER BY book_id DESC)
		List<Book> rows = bookMapper.findPage(q, offset, pageSize);

		// 커스텀 총 페이지를 주입해서 반환
		return new Page<>(rows, safePage, pageSize, total, effectiveTotalPages);
	}

	public Book getById(Long bookId) {
		return bookMapper.findBookById(bookId);
	}
	public Long getPrevId(Long bookId) { return bookMapper.selectPrevId(bookId); }
	public Long getNextId(Long bookId) { return bookMapper.selectNextId(bookId); }

	/** 베스트셀러(DELIVERED 기준, 상위 N권) */
	public List<Map<String, Object>> findBestSellers(int limit) {
		int n = (limit <= 0 ? 5 : Math.min(limit, 20));
		return bookMapper.findBestSellers(n);
	}
	public List<Map<String, Object>> findBestSellers() { return findBestSellers(5); }
}
