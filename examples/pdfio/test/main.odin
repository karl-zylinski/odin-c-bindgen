package pdfio_test

import "core:fmt"
import pio "../pdfio"

main :: proc() {
	pdf := pio.FileCreate("test.pdf", nil, nil, nil, nil, nil)
	pio.FileSetTitle(pdf, "The Test")
	pio.FileSetAuthor(pdf, "Karl")
	page_dict := pio.DictCreate(pdf)
	page := pio.FileCreatePage(pdf, page_dict)
	pio.ContentSetFillColorDeviceRGB(page, 0.6, 0.0, 0.0)
	pio.ContentSetStrokeColorDeviceRGB(page, 0.6, 0.0, 0.0)
	pio.ContentPathRect(page, 100, 100, 300, 300)
	pio.ContentFill(page, false)
	pio.ContentTextBegin(page)
	pio.ContentSetTextFont(page, "Arial", 100);
	pio.ContentSetFillColorDeviceRGB(page, 0.6, 0.0, 1.0)
	pio.ContentSetStrokeColorDeviceRGB(page, 0.6, 0.0, 1.0)
	pio.ContentTextMoveTo(page, 20, 600)

	pio.ContentTextShow(page, true, "Hi!")
	pio.ContentTextEnd(page)
	pio.StreamClose(page)
	pio.FileClose(pdf)
	fmt.println("test.pdf created")
}