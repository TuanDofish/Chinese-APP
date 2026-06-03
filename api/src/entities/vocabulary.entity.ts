import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Lesson } from './lesson.entity';

@Entity('vocabularies')
export class Vocabulary {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  lessonId: number;

  @ManyToOne(() => Lesson, (lesson) => lesson.vocabularies, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column({ unique: true })
  simplified: string;

  @Column({ nullable: true })
  traditional: string;

  @Index()
  @Column({ nullable: true })
  pinyin: string;

  @Column({ name: 'meaning_vi', nullable: true })
  meaningVi: string;

  @Column({ name: 'meaning_en', nullable: true })
  meaningEn: string;

  /** Âm Hán Việt – rất quan trọng với người Việt học tiếng Trung */
  @Index()
  @Column({ name: 'han_viet', nullable: true })
  hanViet: string;

  /** Bộ thủ của chữ Hán (ví dụ: 氵= bộ Thủy) */
  @Column({ nullable: true })
  radical: string;

  /** Loại từ: danh từ, động từ, tính từ, trợ từ... */
  @Column({ name: 'word_type', nullable: true })
  wordType: string;

  @Column({ name: 'hsk_level', type: 'int', default: 1 })
  hskLevel: number;

  /** Các nghĩa chi tiết – mảng JSON [{meaning, wordType, examples:[{cn, py, vi}]}] */
  @Column({ type: 'jsonb', nullable: true })
  definitions: object[];

  /** Ví dụ câu - tương thích ngược [{cn, py, vi}] */
  @Column({ type: 'jsonb', nullable: true })
  examples: object[];

  @Column({ name: 'stroke_count', nullable: true })
  strokeCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
