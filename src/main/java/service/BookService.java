package service;

import java.util.List;
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
		private final int page;       // 1-based
		private final int size;
		private final int totalPages;
		private final int totalElements;

		public Page(List<T> content, int page, int size, int totalElements) {
			this.content = content;
			this.page = page;
			this.size = size;
			this.totalElements = totalElements;
			this.totalPages = (int) Math.ceil((double) totalElements / size);
		}
		public List<T> getContent() { return content; }
		public int getPage() { return page; }
		public int getSize() { return size; }
		public int getTotalPages() { return totalPages; }
		public int getTotalElements() { return totalElements; }
	}

	public Page<Book> search(String q, int page, int size) {
		int pageSize = size <= 0 ? 10 : Math.min(size, 50);
		int safePage = Math.max(page, 1);
		int offset = (safePage - 1) * pageSize;

		int total = bookMapper.count(q);
		List<Book> rows = bookMapper.findPage(q, offset, pageSize);
		return new Page<>(rows, safePage, pageSize, total);
	}

	public Book getById(Long bookId) {
		return bookMapper.findBookById(bookId);
	}
	// BookService
	public Long getPrevId(Long bookId) { return bookMapper.selectPrevId(bookId); }
	public Long getNextId(Long bookId) { return bookMapper.selectNextId(bookId); }

}
