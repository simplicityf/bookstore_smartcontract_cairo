#[starknet::interface]
pub trait IBookstore<TContractState> {
    fn add_book(ref self: TContractState, book_id: felt 252, book_name: felt252, author_name: felt252, serial_no: u8);
    fn update_book(ref self: TContractState, book_id: felt 252, book_name_update: felt252,
    author_name_update: felt252, serial_no_update: u8);
    fn get_book(self: @TContractState) -> Book;
}

#[derive(Copy, Drop, Serde, starknet::Store)]
struct Book {
    book_name: felt252,
    author_name: felt252,
    serial_no: u8
}

#[starknet::contract]
pub mod Classroom {
    use super::{Book, IBookstore};
    use core::starknet::{
        get_caller_address, ContractAddress,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess}
    };
    #[storage]
    struct Storage {
        books: Map<felt252, Student>, // map studentid => student struct ,
        bookStore_owner: ContractAddress,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BookAdded: BookAdded,
        BookUpdated: BookUpdated
    }
    #[derive(Drop, starknet::Event)]
    struct BookAdded {
        book_name: felt252,
        book_id_id: felt252,
        author_name: felt252
        serial_no: u8
    }
    #[derive(Drop, starknet::Event)]
    struct BookUpdated {
        book_name: felt252,
        book_id_id: felt252,
        author_name: felt252
        serial_no: u8
    }

    #[constructor]
    fn constructor(ref self: ContractState, bookStore_owner: ContractAddress) {
        self.bookStore_owner.write(bookStore_owner)
    }

    #[abi(embed_v0)]
    impl BookStoreImpl of IBookstore<ContractState> {
        fn add_book(ref self: TContractState, book_id: felt 252, book_name: felt252, author_name: felt252, serial_no: u8) {
            let bookStore_owner = self.bookStore_owner.read();
            assert(get_caller_address() == bookStore_owner, 'Only owner can add books');
            let book = Book { book_name: book_name, author_name: author_name, serial_no: serial_no };
            self.books.write(book_id, book);
            self.emit(BookAdded { book_name, author_name, serial_no });
        }
        fn update_book(ref self: TContractState, book_id: felt 252, book_name_update: felt252,
    author_name_update: felt252, serial_no_update: u8) {
            let bookStore_owner = self.bookStore_owner.read();
            // assert(bool, felt252)
            assert(get_caller_address() == bookStore_owner, 'Cannot update book record');
            let mut book = self.books.read(student_id);
            book.book_name = book_name_update;
            book.author_name = author_name_update;
            book.serial_no = serial_no_update;
            self.books.write(book_id, book);
            self.emit(BookUpdated { book_name: book.book_name, book_id, author_name: author_name_update, serial_no: serial_no_update });
        }
        fn get_book(self: @TContractState, book_id: felt252) -> Book {
            self.books.read(book_id);
        }
    }
}