Single Item Tender

bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/singleItem__owner__all -v number_of_lots:1
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/singleItem__provider__all
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/singleItem__viewer__all -v number_of_lots:1

Planning

+ bin/op_tests -s planning -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/planning__owner
+ bin/op_tests -s planning -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/planning__viewer

Reporting

bin/op_tests -s reporting -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/reporting__owner
bin/op_tests -s reporting -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/reporting__viewer

Below Funders

bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/belowFunders__owner__all -v number_of_lots:1
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/belowFunders__viewer__all -v number_of_lots:1

OpenEU

bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openEU__owner__all -v number_of_lots:1
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openEU__provider__all
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openEU__viewer__all -v number_of_lots:1

OpenUA

bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openUA__owner__all -v number_of_lots:1
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openUA__provider__all
bin/op_tests -s 01openProcedure -s 02auction -s 03qualification -s 04contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openUA__viewer__all -v number_of_lots:1

Negotiation

bin/op_tests -s negotiation -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/negotiation__owner -v number_of_lots:2
bin/op_tests -s negotiation -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/negotiation__viewer -v number_of_lots:2

Complaints

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__openua_award

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__openua_award

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__openua_award

################################################################################################

Single Item Tender

+/- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/singleItem__owner__openProcedure -v number_of_lots:1
+ bin/op_tests -s auction -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/singleItem__owner__auction -v number_of_lots:1
+ bin/op_tests -s qualification -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/singleItem__owner_qualification
+/- bin/op_tests -s contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/singleItem__owner_contractSigning

+/- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/singleItem__provider__openProcedure
+ bin/op_tests -s auction -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/singleItem__provider__auction
+ bin/op_tests -s qualification -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/singleItem__provider__qualification
+ bin/op_tests -s contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/singleItem__provider__contractSigning

+/- bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/singleItem__viewer__openProcedure -v number_of_lots:1
+ bin/op_tests -s auction -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/singleItem__viewer__auction
+ bin/op_tests -s qualification -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/singleItem__viewer__qualification
+ bin/op_tests -s contract_signing -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/singleItem__viewer__contractSigning

Planning

+ bin/op_tests -s planning -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/planning__owner
+ bin/op_tests -s planning -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/planning__viewer

Reporting

bin/op_tests -s reporting -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/reporting__owner
bin/op_tests -s reporting -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/reporting__viewer

Below Funders

+ bin/op_tests -s openProcedure -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/belowFunders__owner__openProcedure -v number_of_lots:1
+ bin/op_tests -s auction -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/belowFunders__owner__auction
+ bin/op_tests -s qualification -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/belowFunders__owner__qualification
+ bin/op_tests -s contract_signing -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/belowFunders__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/belowFunders__viewer__openProcedure -v number_of_lots:1
bin/op_tests -s auction -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/belowFunders__viewer__auction
bin/op_tests -s qualification -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/belowFunders__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/below_funders.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/belowFunders__viewer__contractSigning

################################################################################################

OpenEU

bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openEU__owner__openProcedure -v number_of_lots:1
bin/op_tests -s auction -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openEU__owner__auction -v number_of_lots:1
bin/op_tests -s qualification -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openEU__owner__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openEU__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openEU__provider__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openEU__provider__auction
bin/op_tests -s qualification -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openEU__provider__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openEU__provider__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openEU__viewer__openProcedure -v number_of_lots:1
bin/op_tests -s auction -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openEU__viewer__auction
bin/op_tests -s qualification -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openEU__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openEU__viewer__contractSigning

OpenUA

bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openUA__owner__openProcedure -v number_of_lots:1
bin/op_tests -s auction -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openUA__owner__auction -v number_of_lots:1
bin/op_tests -s qualification -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openUA__owner__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openUA__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openUA__provider__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openUA__provider__auction
bin/op_tests -s qualification -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openUA__provider__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openUA__provider__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openUA__viewer__openProcedure -v number_of_lots:1
bin/op_tests -s auction -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openUA__viewer__auction
bin/op_tests -s qualification -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openUA__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openUA__viewer__contractSigning

Negotiation

bin/op_tests -s negotiation -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/negotiation__owner -v number_of_lots:2
bin/op_tests -s negotiation -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/negotiation__viewer -v number_of_lots:2

Complaints

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/complaints__owner__openua_award

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/complaints__provider__openua_award

bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below
bin/op_tests -s complaints -A robot_tests_arguments/below_before_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below_before_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/below_after_resolved_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__below_after_resolved_award
bin/op_tests -s complaints -A robot_tests_arguments/openua_tender_lot_complaint.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__openua
bin/op_tests -s complaints -A robot_tests_arguments/openua_award_complaint.txt -v accelerator:number_of_accelerator -v submissionMethodDetails:"quick(mode:fast-forward)" -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/complaints__viewer__openua_award

Open Defense

bin/op_tests -s openProcedure -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openDefense__owner__openProcedure
bin/op_tests -s qualification -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openDefense__owner__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/openDefense__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openDefense__provider__openProcedure
bin/op_tests -s qualification -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openDefense__provider__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/openDefense__provider__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openDefense__viewer__openProcedure
bin/op_tests -s qualification -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openDefense__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/openUAdefense_one_bid.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/openDefense__viewer__contractSigning

CompetitiveDialogueUA

bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/competitiveDialogueUA__owner__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/competitiveDialogueUA__owner__auction
bin/op_tests -s qualification -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/competitiveDialogueUA__owner__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/competitiveDialogueUA__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/competitiveDialogueUA__provider__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/competitiveDialogueUA__provider__auction
bin/op_tests -s qualification -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/competitiveDialogueUA__provider__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/competitiveDialogueUA__provider__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/competitiveDialogueUA__viewer__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/competitiveDialogueUA__viewer__auction
bin/op_tests -s qualification -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/competitiveDialogueUA__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/competitive_dialogue_UA.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/competitiveDialogueUA__viewer__contractSigning

CompetitiveDialogueEU

bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue.txt -v broker:pzo -v role:tender_owner -v api_version:2.4  -d test_output/competitiveDialogueEU__owner__openProcedure
bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue.txt -v broker:pzo -v role:provider -v api_version:2.4  -d test_output/competitiveDialogueEU__provider__openProcedure
bin/op_tests -s openProcedure -A robot_tests_arguments/competitive_dialogue.txt -v broker:pzo -v role:viewer -v api_version:2.4  -d test_output/competitiveDialogueEU__viewer__openProcedure

ESCO

bin/op_tests -s openProcedure -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/esco__owner__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/esco__owner__auction
bin/op_tests -s qualification -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/esco__owner__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.4 -d test_output/esco__owner__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/esco__provider__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/esco__provider__auction
bin/op_tests -s qualification -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/esco__provider__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:provider -v api_version:2.4 -d test_output/esco__provider__contractSigning

bin/op_tests -s openProcedure -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/esco__viewer__openProcedure
bin/op_tests -s auction -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/esco__viewer__auction
bin/op_tests -s qualification -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/esco__viewer__qualification
bin/op_tests -s contract_signing -A robot_tests_arguments/esco_testing.txt -v broker:pzo -v role:viewer -v api_version:2.4 -d test_output/esco__viewer__contractSigning

################################################################################################





















OLD

singleItemTender:
bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:tender_owner -d output/single/owner -v number_of_lots:1
bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:provider -d output/single/provider -v number_of_lots:0
bin/op_tests -s openProcedure -A robot_tests_arguments/single_item_tender.txt -v broker:pzo -v role:viewer -d output/single/viewer -v number_of_lots:1

openEU:
bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.3 -d output/eu/owner
bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:provider -v api_version:2.3 -d output/eu/provider
bin/op_tests -s openProcedure -A robot_tests_arguments/openeu_testing.txt -v broker:pzo -v role:viewer -v api_version:2.3 -d output/eu/viewer

openUA:
bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:tender_owner -v api_version:2.3 -d output/ua/owner
bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:provider -v api_version:2.3 -d output/ua/provider
bin/op_tests -s openProcedure -A robot_tests_arguments/openua_testing.txt -v broker:pzo -v role:viewer -v api_version:2.3 -d output/ua/viewer

negotiation:
bin/op_tests -s negotiation -v number_of_lots:2 -v broker:pzo -v role:tender_owner -v api_version:2.3 -d output/nego/owner
bin/op_tests -s negotiation -v number_of_lots:2 -v broker:pzo -v role:provider -v api_version:2.3 -d output/nego/provider
bin/op_tests -s negotiation -v number_of_lots:2 -v broker:pzo -v role:viewer -v api_version:2.3 -d output/nego/viewer

complaints ‰Ó ÚÂÌ‰Â‡ Ú‡ ÎÓÚ≥‚:
bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:tender_owner -d output/comp/owner -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 120], "tender": [0, 25]}}}}'
bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:provider -d output/comp/provider -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 120], "tender": [0, 25]}}}}'
bin/op_tests -s complaints -A robot_tests_arguments/below_tender_lot_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:viewer -d output/comp/viewer -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 60], "tender": [0, 25]}}}}'


complaints ‰Ó ‡‚‡‰Ó‚:
bin/op_tests -s complaints -A robot_tests_arguments/below_award_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:tender_owner -d output/comp2/owner -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 8], "tender": [0, 13]}}}}'
bin/op_tests -s complaints -v accelerator:90 -v submissionMethodDetails:"quick(mode:fast-forward)" -A robot_tests_arguments/below_award_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:provider -d output/comp2/provider -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 8], "tender": [0, 13]}}}}'
bin/op_tests -s complaints -v accelerator:90 -v submissionMethodDetails:"quick(mode:fast-forward)" -A robot_tests_arguments/below_award_complaint.txt -v API_VERSION:2.3 -v BROKER:pzo -v role:viewer -d output/comp2/viewer -v BROKERS_PARAMS:'{"pzo": {"intervals": {"belowThreshold": {"enquiry": [0, 8], "tender": [0, 13]}}}}'
