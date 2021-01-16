.include "m328Pdef.inc" //นำเข้า AVR definition file
.equ All_PIN_OUT = 0xff 
.equ ALL_PIN_IN = 0x00
.def VAR_A = R16 //เซ็นเซอร์อุณหภูมิ
.def TMP = R17
.def FAN = R18 //พัดลม
.def CHECK = R19
;-------------
;Code segment
;-------------
.CSEG
.ORG	0x0000
	ldi VAR_A, ALL_PIN_OUT //โหลด ALL_PIN_OUT มาใส่ใน VAR_A
	out DDRB, VAR_A //กำหนดให้ PORT B เป็น  output ของวงจร
	ldi VAR_A, ALL_PIN_IN //โหลด ALL_PIN_IN มาใส่ใน VAR_A
	out DDRD, VAR_A //กำหนดให้ PORT D เป็น input ของวงจร
	ldi TMP, 0x00 //โหลดค่า 0 มาใส่ใน TMP

	ldi CHECK, 0b1111_1111 // โหลดค่า 0b1111_1111 ใส่ใน CHECK
	out DDRC, CHECK //กำหนดให้ PORT C เป็น output ของวงจร
MAIN:
	in VAR_A, PIND //กำหนดให้ PIND เป็น input ของวงจรโดยเก็บใน VAR_A
	andi VAR_A, 0b0001_0000  //นำค่าของ VAR_A ไป AND กับ ขา 4 
	mov CHECK, VAR_A //move ค่าที่ได้ไปเก้บใน CHECK
	lsr CHECK //ทำการเลื่อนบิตของ CHECK
	out PORTC, CHECK // กำหนดให้ CHECK เป็น output ออกทาง LED
	cpi VAR_A, 0b0000_0000 //เปรียบเทียบค่า VAR_A กับ 0x00
	breq SET_VAR_A_HOT //หากได้ 0 จะ branch ไปยัง SET_VAR_HOT
	rjmp SET_VAR_A_NORMAL //กระโดดไปยังฟังก์ชั่น SET_VAR_NORMAL

SET_VAR_A_NORMAL: //ปกติ
	ldi VAR_A, 0x00 //โหลด 0x00 มาใส่ใน VAR_A
	ldi FAN, 0b0000_0000 //โหลด 0 ใส่ในขา 7(พัดลม) ทำให้พัดลมไม่หมุน
	rcall FAN_CONTROL //เรียกซับรูทีน FAN_CONTROLL
	rjmp DISPLAY7SEG //กระโดดไปยังฟังก์ชั่น DISPLAY7SEG
SET_VAR_A_HOT: //ร้อน
	ldi VAR_A, 0x01 //โหลด 0x01 มาใส่ใน VAR_A
	ldi FAN, 0b1000_0000 //โหลด 1 ใส่ในขา 7(พัดลม) ทำให้พัดลมหมุน
	rcall FAN_CONTROL //เรียกซับรูทีน FAN_CONTROLL
	rjmp DISPLAY7SEG //กระโดดไปยังฟังก์ชั่น DISPLAY7SEG

DISPLAY7SEG:
	ldi ZL,low(TB_7SEGMENT*2) //เก็บข้อมูล 2 ไบต์low
	ldi ZH,high(TB_7SEGMENT*2) //เก็บข้อมูล 2 ไบต์High
	add ZL,VAR_A //บวกค่าระหว่าง ZL และ VAR_A 
	adc ZH,TMP //บวกแบบมีตัวทดระหว่าง ZH และตัว TMP
	lpm //เก็บข้อมูลไว้ใน R0 โดยผ่านการชี้ข้อมูลจาก Z 
	out PORTB, R0 //แสดงค่า R0 ออกจาก 7-segment
	rjmp MAIN 

FAN_CONTROL:
	out PORTD, FAN //นำค่าใน FAN ไปแสดงผลออกทางพัดลม
	ret 
	
;-----------------------
;Table for 7-seg display
;-----------------------
TB_7SEGMENT: 
	.DB 0b0011_1111, 0b0000_0110 ; 0  and 1 
.DSEG
.ESEG
