Single Item Tender

- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -v number_of_lots:1
- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4
- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4
